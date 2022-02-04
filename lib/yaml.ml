(* Copyright (c) 2017 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. *)

include Types

module Util = Util
module Stream = Stream
open Stream

let (>>=) = Result.bind

let scalar ?anchor ?tag ?(plain_implicit=true) ?(quoted_implicit=false)
    ?(style=`Plain) value =
  { anchor; tag; plain_implicit; quoted_implicit; style; value }

let yaml_scalar_to_json t =
  match t with
  | "null" | "NULL" | "" | "Null" | "~" -> `Null
  | "y"|"Y"|"yes"|"Yes"|"YES"
  | "true"|"True"|"TRUE"
  | "on"|"On"|"ON" -> `Bool true
  | "n"|"N"|"no"|"No"|"NO"
  | "false"|"False"|"FALSE"
  | "off"|"Off"|"OFF" -> `Bool false
  | "-.inf" -> `Float neg_infinity
  | ".inf" -> `Float infinity
  | ".nan"|".NaN"|".NAN" -> `Float nan
  | s -> (try `Float (float_of_string s) with _ -> `String s)

let to_json v =
  let rec fn = function
   (* Quoted implicts are represented as strings in Json. *)
   | `Scalar {value; quoted_implicit=true} -> `String value
   | `Scalar {value} -> yaml_scalar_to_json value
   | `Alias _ -> failwith "Anchors are not supported when serialising to JSON"
   | `A {s_members} -> `A (List.map fn s_members)
   | `O {m_members} ->
      let simple_key_to_string =
        function
        | `Scalar {anchor;value} -> value
        | k -> failwith "non-string key is not supported"
      in
      `O (List.map (fun (k,v) -> simple_key_to_string k, fn v) m_members)
  in
  match fn v with
  | r -> Ok r
  | exception (Failure msg) -> Error (`Msg msg)

let of_json (v:value) =
  let rec fn = function
  | `Null -> `Scalar (scalar "")
  | `Bool b -> `Scalar (scalar (string_of_bool b))
  | `Float f -> `Scalar (scalar (string_of_float f))
  | `String value -> `Scalar (scalar value)
  | `A l -> `A {s_anchor=None; s_tag=None; s_implicit=true; s_members=List.map fn l}
  | `O l -> `O {m_anchor=None; m_tag=None; m_implicit=true; m_members=List.map (fun (k,v) -> `Scalar (scalar k), (fn v)) l}
  in match fn v with
  | r -> Ok r
  | exception (Failure msg) -> Error (`Msg msg)

let to_string ?len ?(encoding=`Utf8) ?scalar_style ?layout_style (v:value) =
  emitter ?len () >>= fun t ->
  stream_start t encoding >>= fun () ->
  document_start t >>= fun () ->
  let rec iter = function
     |`Null -> Stream.scalar (scalar "") t
     |`String s ->
        let style =
          match yaml_scalar_to_json s with
          | `String s -> scalar_style
          | _ -> Some `Double_quoted
        in
        Stream.scalar (scalar ?style ~quoted_implicit:true s) t
     |`Float s -> Stream.scalar (scalar (Printf.sprintf "%.16g" s)) t
     (* NOTE: Printf format on the line above taken from the jsonm library *)
     |`Bool s -> Stream.scalar (scalar (string_of_bool s)) t
     |`A l ->
        sequence_start ?style:layout_style t >>= fun () ->
        let rec fn = function
          | [] -> sequence_end t
          | hd::tl -> iter hd >>= fun () -> fn tl
        in fn l
     |`O l ->
        mapping_start ?style:layout_style t >>= fun () ->
        let rec fn = function
          | [] -> mapping_end t
          | (k,v)::tl -> iter (`String k) >>= fun () -> iter v >>= fun () -> fn tl
        in fn l
  in
  iter v >>= fun () ->
  document_end t >>= fun () ->
  stream_end t >>= fun () ->
  let r = Stream.emitter_buf t in
  Ok (Bytes.to_string r)

let to_string_exn ?len ?encoding ?scalar_style ?layout_style s =
  match to_string ?len ?encoding ?scalar_style ?layout_style s with
  | Ok s -> s
  | Error (`Msg m) -> raise (Invalid_argument m)


let yaml_to_string ?(encoding=`Utf8) ?scalar_style ?layout_style v =
  emitter () >>= fun t ->
  stream_start t encoding >>= fun () ->
  document_start t >>= fun () ->
  let rec iter = function
    |`Scalar s -> Stream.scalar s t
    |`Alias anchor -> alias t anchor
    |`A {s_anchor=anchor; s_tag=tag; s_implicit=implicit; s_members} ->
        sequence_start ?anchor ?tag ~implicit ?style:layout_style t >>= fun () ->
        let rec fn = function
          | [] -> sequence_end t
          | hd::tl -> iter hd >>= fun () -> fn tl
        in fn s_members
     |`O {m_anchor=anchor; m_tag=tag; m_implicit=implicit; m_members} ->
        mapping_start ?anchor ?tag ~implicit ?style:layout_style t >>= fun () ->
        let rec fn = function
          | [] -> mapping_end t
          | (k,v)::tl -> iter k >>= fun () -> iter v >>= fun () -> fn tl
        in fn m_members
  in
  iter v >>= fun () ->
  document_end t >>= fun () ->
  stream_end t >>= fun () ->
  let r = Stream.emitter_buf t in
  Ok (Bytes.to_string r)

let yaml_of_string s =
  let open Event in
  parser s >>= fun t ->
  let next () =
   do_parse t >>= fun (e, pos) ->
   Ok (e,pos) in
  next () >>= fun (e,pos) ->
  match e with
  | Stream_start _ -> begin
    next () >>= fun (e,pos) ->
    match e with
    | Document_start _ -> begin
       let rec parse_v (e,pos) =
         match e with
         | Sequence_start {anchor; tag; implicit; style = _} ->
            next () >>=
            parse_seq [] >>= fun s ->
            Ok (`A {s_anchor = anchor; s_tag = tag; s_implicit = implicit; s_members = s})
         | Scalar scalar -> Ok (`Scalar scalar)
         | Alias {anchor} -> Ok (`Alias anchor)
         | Mapping_start {anchor; tag; implicit; style = _} ->
            next () >>=
            parse_map [] >>= fun s ->
            Ok (`O {m_anchor = anchor; m_tag = anchor; m_implicit = implicit; m_members = s})
         | e -> Error (`Msg "todo")
       and parse_seq acc (e,pos) =
         match e with
         | Sequence_end -> Ok (List.rev acc)
         | e ->
           parse_v (e,pos) >>= fun v ->
           next () >>=
           parse_seq (v :: acc)
       and parse_map acc (e,pos) =
         match e with
         | Mapping_end -> Ok (List.rev acc)
         | e -> begin
             parse_v (e,pos) >>= fun k ->
             next () >>=
             parse_v >>= fun v ->
             next () >>=
             parse_map ((k,v)::acc)
         end
       in
       next () >>=
       parse_v
    end
    | Stream_end -> Ok (`Scalar (scalar ""))
    | e -> Error (`Msg "Not document start")
  end
  | _ -> Error (`Msg "Not stream start")

let of_string s = yaml_of_string s >>= to_json

let of_string_exn s =
  match of_string s with
  | Ok s -> s
  | Error (`Msg m) -> raise (Invalid_argument m)

let pp ppf s =
  match to_string s with
  | Ok s -> Format.pp_print_string ppf s
  | Error (`Msg m) -> Format.pp_print_string ppf (Printf.sprintf "(error (%s))" m)

let rec equal v1 v2 =
  match v1, v2 with
  | `Null, `Null -> true
  | `Bool x1, `Bool x2 -> ((=) : bool -> bool -> bool) x1 x2
  | `Float x1, `Float x2 -> ((=) : float -> float -> bool) x1 x2
  | `String x1, `String x2 -> String.equal x1 x2
  | `A xs1, `A xs2 -> List.for_all2 equal xs1 xs2
  | `O xs1, `O xs2 ->
      List.for_all2 (fun (k1, v1) (k2, v2) ->
        String.equal k1 k2 && equal v1 v2) xs1 xs2
  | _ -> false
