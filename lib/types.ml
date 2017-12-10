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

open Sexplib.Conv

type version = [
 | `V1_0
 | `V1_1 
] [@@deriving sexp]

type encoding = [
 | `Any
 | `Utf16be
 | `Utf16le
 | `Utf8  ]
[@@deriving sexp]

type scalar_style = [
 | `Any
 | `Plain
 | `Single_quoted
 | `Double_quoted
 | `Literal
 | `Folded ]
[@@deriving sexp]

type layout_style = [
  | `Any
  | `Block
  | `Flow
] [@@deriving sexp]

type value =
  [ `Null
  | `Bool of bool
  | `Float of float
  | `String of string
  | `A of value list
  | `O of (string * value) list
] [@@deriving sexp]

type anchor_string = {
  anchor: string option;
  value: string;
} [@@deriving sexp]

type yaml =
  [ `String of anchor_string
  | `Alias of string
  | `A of yaml list
  | `O of (anchor_string * yaml) list
] [@@deriving sexp]

type 'a res = ('a, Rresult.R.msg) Result.result
