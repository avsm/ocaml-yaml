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

module T = Yaml_types.M
open Rresult

let reflect e ev pos =
  Yaml.Stream.emit e ev

let v file =
  let open R.Infix in
  Bos.OS.File.read file >>= fun buf ->
  Yaml.Stream.parser buf >>= fun t ->
  Yaml.Stream.emitter () >>= fun e ->
  let rec iter_until_done fn =
    Yaml.Stream.do_parse t >>= fun (e, pos) ->
    match e with 
    | Yaml.Stream.Event.Nothing -> R.ok ()
    | event -> fn event pos; iter_until_done fn in
  iter_until_done (reflect e) >>= fun () ->
  let r = Yaml.Stream.emitter_buf e in
  print_endline buf;
  print_endline (Bytes.to_string r); 
  Ok ()
