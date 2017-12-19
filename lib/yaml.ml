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
open Rresult
open R.Infix

module Stream = Stream
open Stream

let to_json v =
  let rec fn = function
   | `String {value} -> `String value
   | `Alias _ -> failwith "Anchors are not supported when serialising to JSON"
   | `A l -> `A (List.map fn l)
   | `O l -> `O (List.map (fun ({anchor;value},v) -> value, (fn v)) l)
  in
  match fn v with
  | r -> Ok r
  | exception (Failure msg) -> R.error_msg msg

let of_json (v:value) =
  let rec fn = function
  | `Null -> `String {anchor=None;value=""}
  | `Bool b -> `String {anchor=None;value=string_of_bool b}
  | `Float f -> `String {anchor=None;value=string_of_float f}
  | `String value -> `String {anchor=None; value}
  | `A l -> `A (List.map fn l)
  | `O l -> `O (List.map (fun (k,v) -> {anchor=None;value=k}, (fn v)) l)
  in match fn v with
  | r -> Ok r
  | exception (Failure msg) -> R.error_msg msg
 
let to_string ?len ?(encoding=`Utf8) ?scalar_style ?layout_style (v:value) =
  emitter ?len () >>= fun t ->
  stream_start t encoding >>= fun () ->
  document_start t >>= fun () ->
  let rec iter = function
     |`Null -> scalar t ""
     |`String s -> scalar ?style:scalar_style t s
     |`Float s -> string_of_float s |> scalar t
     |`Bool s -> string_of_bool s |> scalar t
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
    |`String {anchor;value} -> scalar ?anchor ?style:scalar_style t value
    |`Alias anchor -> alias t anchor
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

let yaml_of_string s =
  let open Event in
  parser s >>= fun t ->
  let next () =
   do_parse t >>= fun (e, pos) ->
   Logs.debug (fun l -> l "event %s\n%!" (sexp_of_t e |> Sexplib.Sexp.to_string_hum));
   Ok (e,pos) in
  next () >>= fun (e,pos) ->
  match e with
  | Stream_start _ -> begin
    next () >>= fun (e,pos) ->
    match e with
    | Document_start _ -> begin
       let rec parse_v (e,pos) =
         match e with
         | Sequence_start _ ->
            next () >>=
            parse_seq [] >>= fun s ->
            Ok (`A s)
         | Scalar {anchor;value} -> Ok (`String {anchor;value})
         | Alias {anchor} -> Ok (`Alias anchor)
         | Mapping_start _ ->
            next () >>=
            parse_map [] >>= fun s ->
            Ok (`O s)
         | e -> R.error_msg (Fmt.strf "todo %s (%s)" (sexp_of_t e |> Sexplib.Sexp.to_string_hum) (sexp_of_pos pos |> Sexplib.Sexp.to_string_hum))
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
             parse_v (e,pos) >>= fun v ->
             begin match v with
             | `String k ->
                next () >>= 
                parse_v >>= fun v ->
                next () >>=
                parse_map ((k,v)::acc)
             | _ -> R.error_msg (Fmt.strf "only string keys are supported (%s)" (sexp_of_pos pos |> Sexplib.Sexp.to_string_hum))
             end
         end
       in
       next () >>= 
       parse_v
    end
    | Stream_end -> Ok (`String {anchor=None;value=""})
    | e -> R.error_msg (Fmt.strf "Not document start: %s" (sexp_of_t e |> Sexplib.Sexp.to_string_hum))
  end
  | _ -> R.error_msg "Not stream start"

let of_string s = yaml_of_string s >>= to_json

let of_string_exn s =
  match of_string s with
  | Ok s -> s
  | Error (`Msg m) -> raise (Invalid_argument m)

let pp ppf s =
  match to_string s with
  | Ok s -> Format.pp_print_string ppf s
  | Error (`Msg m) -> Format.pp_print_string ppf (Printf.sprintf "(error (%s))" m)
