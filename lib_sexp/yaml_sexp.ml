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

open Sexplib0.Sexp_conv

type value =
  [ `Null
  | `Bool of bool
  | `Float of float
  | `String of string
  | `A of value list
  | `O of (string * value) list
] [@@deriving sexp]

type yaml =
  [ `Scalar of scalar
  | `Alias of string
  | `A of sequence
  | `O of mapping
] [@@deriving sexp]

and sequence = Yaml.sequence = {
  s_anchor: string option;
  s_tag: string option;
  s_implicit: bool;
  s_members: yaml list
} [@@deriving sexp]

and mapping = Yaml.mapping = {
  m_anchor: string option;
  m_tag: string option;
  m_implicit: bool;
  m_members: (yaml * yaml) list
} [@@deriving sexp]

and scalar = Yaml.scalar = {
  anchor: string option;
  tag: string option;
  value: string;
  plain_implicit: bool;
  quoted_implicit: bool;
  style: scalar_style
} [@@deriving sexp]

and scalar_style = [
  | `Any
  | `Plain
  | `Single_quoted
  | `Double_quoted
  | `Literal
  | `Folded ]
[@@deriving sexp]

type version = [ `V1_1 | `V1_2 ] [@@deriving sexp]

type encoding = [ `Any | `Utf16be | `Utf16le | `Utf8 ] [@@deriving sexp]

type layout_style = [
  | `Any
  | `Block
  | `Flow
] [@@deriving sexp]

module Stream = struct
  module Mark = struct
    type t = Yaml.Stream.Mark.t =
      { index: int
      ; line: int
      ; column: int }
      [@@deriving sexp]
  end

  module Event = struct
    type pos = Yaml.Stream.Event.pos = {start_mark: Mark.t; end_mark: Mark.t} [@@deriving sexp]

    type t = Yaml.Stream.Event.t =
      | Stream_start of { encoding: encoding}
      | Document_start of { version: version option; implicit: bool}
      | Document_end of { implicit: bool}
      | Mapping_start of
          { anchor: string option
          ; tag: string option
          ; implicit: bool
          ; style: layout_style }
      | Mapping_end
      | Stream_end
      | Scalar of scalar
      | Sequence_start of
          { anchor: string option
          ; tag: string option
          ; implicit: bool
          ; style: layout_style }
      | Sequence_end
      | Alias of { anchor: string}
      | Nothing
      [@@deriving sexp]
  end
end
