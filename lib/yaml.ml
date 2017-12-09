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

let library_version = get_version

let to_string ?scalar_style ?mapping_style ?sequence_style (v:value) =
  emitter () >>= fun t ->
  stream_start t `Utf8 >>= fun () ->
  document_start t >>= fun () ->
  let rec iter = function
     |`Null -> scalar t ""
     |`String s -> scalar ?style:scalar_style t s
     |`Float s -> string_of_float s |> scalar t
     |`Bool s -> string_of_bool s |> scalar t
     |`A l -> 
        sequence_start ?style:sequence_style t >>= fun () ->
        let rec fn = function
          | [] -> sequence_end t
          | hd::tl -> iter hd >>= fun () -> fn tl
        in fn l
     |`O l ->
        mapping_start ?style:mapping_style t >>= fun () ->
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
 
let of_string s =
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
         | Scalar {value} -> Ok (`String value)
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
    | _ -> R.error_msg "Not document start"
  end
  | _ -> R.error_msg "Not stream start"

