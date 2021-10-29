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

type version = [
 | `V1_1
 | `V1_2
]

type encoding = [
 | `Any
 | `Utf16be
 | `Utf16le
 | `Utf8  ]

type scalar_style = [
 | `Any
 | `Plain
 | `Single_quoted
 | `Double_quoted
 | `Literal
 | `Folded ]

type layout_style = [
  | `Any
  | `Block
  | `Flow
]

type value =
  [ `Null
  | `Bool of bool
  | `Float of float
  | `String of string
  | `A of value list
  | `O of (string * value) list
]

type scalar = {
  anchor: string option;
  tag: string option;
  value: string;
  plain_implicit: bool;
  quoted_implicit: bool;
  style: scalar_style
}

type yaml =
  [ `Scalar of scalar
  | `Alias of string
  | `A of sequence
  | `O of mapping
]

and sequence = {
  s_anchor: string option;
  s_tag: string option;
  s_implicit: bool;
  s_members: yaml list
}

and mapping = {
  m_anchor: string option;
  m_tag: string option;
  m_implicit: bool;
  m_members: (yaml * yaml) list
}

type 'a res = ('a, [`Msg of string]) result
