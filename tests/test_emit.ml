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

open Rresult
open R.Infix

module S = Yaml.Stream

let scalar ?anchor ?tag ?(plain_implicit=true) ?(quoted_implicit=false)
    ?(style=`Plain) value : Yaml.scalar =
  { anchor; tag; plain_implicit; quoted_implicit; style; value }

let v () =
  S.emitter () >>= fun t ->
  S.stream_start t `Utf8 >>= fun () ->
  S.document_start t >>= fun () ->
  S.sequence_start t >>= fun () ->
  S.scalar (scalar ~tag:"sup" "foo1") t >>= fun () ->
  S.mapping_start ~tag:"xx" t >>= fun () ->
  S.scalar (scalar ~tag:"sup" "foo2") t >>= fun () ->
  S.scalar (scalar ~tag:"sup" "bar3") t >>= fun () ->
  S.mapping_end t >>= fun () ->
  S.mapping_start t >>= fun () ->
  S.scalar (scalar ~tag:"bar" "foo4") t >>= fun () ->
  S.sequence_start t >>= fun () ->
  S.scalar (scalar ~tag:"bar" "foo5") t >>= fun () ->
  S.scalar (scalar ~tag:"bar2" "foo6") t >>= fun () ->
  S.scalar (scalar ~tag:"bar3" "foo7") t >>= fun () ->
  S.sequence_end t >>= fun () ->
  S.mapping_end t >>= fun () ->
  S.sequence_end t >>= fun () ->
  S.document_end t >>= fun () ->
  S.stream_end t >>= fun () ->
  Printf.printf "written: %d\n%!" (S.emitter_written t);
  let r = S.emitter_buf t in
  print_endline (Bytes.to_string r);
  Ok ()

