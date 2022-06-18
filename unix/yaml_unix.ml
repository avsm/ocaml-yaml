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

let of_file f = Result.bind (OS.File.read f) Yaml.of_string
let to_file f y = OS.File.with_oc f Yaml.to_channel y |> Result.join

let of_file_exn f =
  match of_file f with Ok v -> v | Error (`Msg m) -> raise (Failure m)

let to_file_exn f v =
  match to_file f v with Ok () -> () | Error (`Msg m) -> raise (Failure m)

(* TODO: stubs not foreign *)
let c_fopen = Ctypes.(Foreign.foreign "fopen" (string @-> string @-> returning (ptr void)))
let c_fclose = Ctypes.(Foreign.foreign "fclose" (ptr void @-> returning int))

let to_file_fast f y =
  (* TODO: error handling *)
  let file = c_fopen (Fpath.to_string f) "w" in
  Yaml.to_file_fast file y >>= fun () ->
  ignore (c_fclose file);
  Ok ()
