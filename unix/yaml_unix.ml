(* Copyright (c) 2018 Anil Madhavapeddy <anil@recoil.org>
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

open Bos

let ( >>= ) = Result.bind

(* TODO: stubs not foreign *)
let fdopen = Ctypes.(Foreign.foreign "fdopen" (int @-> string @-> returning (ptr void)))

let to_channel ?(encoding = `Utf8) ?scalar_style ?layout_style oc (v : Yaml.value) =
  let handler buf len =
    let buf' = Ctypes.(coerce (ptr uchar) (ptr char) buf) in
    let s = Ctypes.(string_from_ptr buf' ~length:(Unsigned.Size_t.to_int len)) in
    output_string oc s;
    1
  in
  Yaml.Stream.emitter_handler handler >>= fun t ->
  Yaml.to_emitter ~encoding ?scalar_style ?layout_style t v

let of_file f = Result.bind (OS.File.read f) Yaml.of_string
let to_file f y = OS.File.with_oc f to_channel y |> Result.join

let of_file_exn f =
  match of_file f with Ok v -> v | Error (`Msg m) -> raise (Failure m)

let to_file_exn f v =
  match to_file f v with Ok () -> () | Error (`Msg m) -> raise (Failure m)
