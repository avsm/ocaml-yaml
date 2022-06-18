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

(** UNIX interface functions for handling Yaml *)

val of_file : Fpath.t -> (Yaml.value, [ `Msg of string ]) result
(** [of_file p] will read the whole of the file at path [p] and convert it in a
    {!Yaml.value}. *)

val of_file_exn : Fpath.t -> Yaml.value
(** [of_file_exn p] acts as {!of_file}, but errors are thrown as a {!Failure}
    exception instead of in the return value. *)

val to_file :
  ?encoding:Yaml.encoding ->
  ?scalar_style:Yaml.scalar_style ->
  ?layout_style:Yaml.layout_style ->
  Fpath.t ->
  Yaml.value ->
  unit Yaml.res
(** [to_file p v] will convert the Yaml value [v] to a Yaml representation
    and write it to the file at path [p]. The [encoding], [scalar_style] and [layout_style]
    control the various output parameters. *)

val to_file_exn :
  ?encoding:Yaml.encoding ->
  ?scalar_style:Yaml.scalar_style ->
  ?layout_style:Yaml.layout_style ->
  Fpath.t ->
  Yaml.value ->
  unit
(** [to_file_exn p] acts as {!to_file}, but errors are thrown as a {!Failure}
    exception instead of in the return value. *)

val to_file_fast :
  ?encoding:Yaml.encoding ->
  ?scalar_style:Yaml.scalar_style ->
  ?layout_style:Yaml.layout_style ->
  Fpath.t ->
  Yaml.value ->
  unit Yaml.res
(** [to_file_fast p v] will convert the Yaml value [v] to a Yaml representation
    and write it to the file at path [p]. The [encoding], [scalar_style] and [layout_style]
    control the various output parameters.
    Unlike {!to_file}, this function writes the file directly in libyaml instead of going through OCaml. *)
