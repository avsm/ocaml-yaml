(* Copyright (c) 2017 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2021 Alan J Hu <alanh@ccs.neu.edu>
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

val sexp_of_value : Yaml.value -> Sexplib0.Sexp.t
val value_of_sexp : Sexplib0.Sexp.t -> Yaml.value

val sexp_of_yaml : Yaml.yaml -> Sexplib0.Sexp.t
val sexp_of_scalar : Yaml.scalar -> Sexplib0.Sexp.t
val sexp_of_scalar_style : Yaml.scalar_style -> Sexplib0.Sexp.t
val yaml_of_sexp : Sexplib0.Sexp.t -> Yaml.yaml
val scalar_of_sexp : Sexplib0.Sexp.t -> Yaml.scalar
val scalar_style_of_sexp : Sexplib0.Sexp.t -> Yaml.scalar_style

val sexp_of_yaml : Yaml.yaml -> Sexplib0.Sexp.t
val sexp_of_scalar : Yaml.scalar -> Sexplib0.Sexp.t
val sexp_of_scalar_style : Yaml.scalar_style -> Sexplib0.Sexp.t
val yaml_of_sexp : Sexplib0.Sexp.t -> Yaml.yaml
val scalar_of_sexp : Sexplib0.Sexp.t -> Yaml.scalar
val scalar_style_of_sexp : Sexplib0.Sexp.t -> Yaml.scalar_style

val sexp_of_version : Yaml.version -> Sexplib0.Sexp.t
val version_of_sexp : Sexplib0.Sexp.t -> Yaml.version

val sexp_of_layout_style : Yaml.layout_style -> Sexplib0.Sexp.t
val layout_style_of_sexp : Sexplib0.Sexp.t -> Yaml.layout_style

module Stream : sig
  module Mark : sig
    val t_of_sexp : Sexplib0.Sexp.t -> Yaml.Stream.Mark.t
    val sexp_of_t : Yaml.Stream.Mark.t -> Sexplib0.Sexp.t
  end

  module Event : sig
    val sexp_of_pos : Yaml.Stream.Event.pos -> Sexplib0.Sexp.t
    val pos_of_sexp : Sexplib0.Sexp.t -> Yaml.Stream.Event.pos

    val t_of_sexp : Sexplib0.Sexp.t -> Yaml.Stream.Event.t
    val sexp_of_t : Yaml.Stream.Event.t -> Sexplib0.Sexp.t
  end
end
