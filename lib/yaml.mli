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

(** An OCaml library for parsing and emitting YAML.

    It is based on a binding to {{:http://pyyaml.org/wiki/LibYAML:}libyaml}
    which covers the generation and parsing processes.
    The {!Stream} module binds the low-level event interface which has a:
    - {!Stream.parser}, which takes an input stream of bytes and produces a sequence of parsing events.
    - Emitter, which takes a sequence of events and produces a stream of bytes.

  The processes of parsing and presenting are inverse to each other. Any sequence of events
  produced by parsing a well-formed YAML document should be acceptable by the Emitter,
  which should produce an equivalent document.  Similarly, any document produced by emitting a
  sequence of events should be acceptable for the Parser, which should produce an equivalent
  sequence of events.
 *)

(** Version of the YAML spec of a document. *)
type version = V1_0 | V1_1 [@@deriving sexp]

(** Document encoding. *)
type encoding = Any | Utf16be | Utf16le | Utf8 [@@deriving sexp]

(** *)
type scalar_style =
  | Any
  | Plain
  | Single_quoted
  | Double_quoted
  | Literal
  | Folded
  [@@deriving sexp]

(** Low-level event streaming interface for parsing and emitting YAML files. *)
module Stream : sig
  (** Position information for an event *)
  module Mark : sig
    type t =
      { index: int  (** position in characters *)
      ; line: int  (** line number *)
      ; column: int  (** column number *) }
      [@@deriving sexp]
  end

  (** Definition of an individual event during a processing stream *)
  module Event : sig
    (** Delimited positioning information for an event in the document. *)
    type pos = {start_mark: Mark.t; end_mark: Mark.t} [@@deriving sexp]

    (** [t] represents a single event in a YAML processing stream.

    These may be produced by a {!parser} or consumed by an {!emitter}.
    A valid sequence of events should obey the grammar:
    - [stream ::= STREAM-START document* STREAM-END]
    - [document ::= DOCUMENT-START node DOCUMENT-END]
    - [node ::= ALIAS | SCALAR | sequence | mapping]
    - [sequence ::= SEQUENCE-START node* SEQUENCE-END]
    - [mapping ::= MAPPING-START (node node)* MAPPING-END] *)
    type t =
      | Stream_start of {pos: pos; encoding: encoding}
      | Document_start of {pos: pos; version: version option; implicit: bool}
      | Document_end of {pos: pos; implicit: bool}
      | Mapping_start of
          { pos: pos
          ; anchor: string option
          ; tag: string option
          ; implicit: bool
          ; style: scalar_style }
      | Mapping_end of {pos: pos}
      | Stream_end of {pos: pos}
      | Scalar of
          { pos: pos
          ; anchor: string option
          ; tag: string option
          ; value: string
          ; plain_implicit: bool
          ; quoted_implicit: bool
          ; style: scalar_style }
      | Sequence_start of
          { pos: pos
          ; anchor: string option
          ; tag: string option
          ; implicit: bool
          ; style: scalar_style }
      | Sequence_end of {pos: pos}
      | Alias of {pos: pos; anchor: string}
      | Nothing of {pos: pos}
      [@@deriving sexp]
  end

  type parser
  (** [parser] tracks the state of generating {!Event.t} values. *)

  val parser : unit -> (parser, [> Rresult.R.msg]) Result.result
  (** [parser ()] will allocate a fresh parser state. *)

  val set_input_string : parser -> string -> unit
  (** [set_input_string parser buf] will initialise a {!parser} to use the
      [buf] value and start processing it. *)

  val do_parse : parser -> (Event.t, [> Rresult.R.msg]) Result.result
  (** [do_parse parser] will generate the next parsing event from an
      initialised parser.  *)
end
