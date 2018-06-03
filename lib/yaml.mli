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

(** A library for parsing and emitting YAML.

  It is based on a binding to {{:http://pyyaml.org/wiki/LibYAML:}libyaml}
  which covers the generation and parsing processes.
 
  Most simple use cases can simply use the {!of_string} and {!to_string}
  functions, which are compatible with the {!Ezjsonm} types.  This means
  that you can convert between JSON and Yaml format easily.

  If you use more advanced Yaml features such as aliases or anchors,
  then the {!yaml} type and {!yaml_of_string} and {!yaml_to_string}
  functions will be more useful.  The library does not yet support
  expanding aliases into the JSON format from YAML, so that will
  currently result in an error.
 *)

(** {2 Types} *)

type value =
  [ `Null
  | `Bool of bool
  | `Float of float
  | `String of string
  | `A of value list
  | `O of (string * value) list
] [@@deriving sexp]
(** [value] is the subset of a Yaml document that is compatible
  with JSON.  This type is the same as {!Ezjsonm.value}, and so
  most simple uses of Yaml can be interchanged with JSON. *)

type yaml =
  [ `String of anchor_string
  | `Alias of string
  | `A of yaml list
  | `O of (anchor_string * yaml) list
]
(** [yaml] is the representation of a Yaml document that
  preserves alias information and other Yaml-specific metadata
  that cannot be represented in JSON.  It is not recommended
  to convert untrusted Yaml with aliases into JSON due to the
  risk of denial-of-service via a
  {{:https://en.wikipedia.org/wiki/Billion_laughs_attack}Billion Laughs attack}. *)
and anchor_string = {
  anchor: string option;
  value: string;
} [@@deriving sexp]
(** [anchor_string] holds a possible Yaml anchor, and the string [value] *)

type version = [ `V1_0 | `V1_1 ] [@@deriving sexp]
(** Version of the YAML spec of a document.
  Refer to the {{:http://www.yaml.org/spec/1.2/spec.html}Yaml specification}
  for details of the differences between versions. *)

type encoding = [ `Any | `Utf16be | `Utf16le | `Utf8 ] [@@deriving sexp]
(** Document encoding. The recommended format is [Utf8]. *)

type scalar_style = [
  | `Any
  | `Plain
  | `Single_quoted
  | `Double_quoted
  | `Literal
  | `Folded ]
  [@@deriving sexp]
(** YAML provides three flow scalar styles: double-quoted, single-quoted
  and plain (unquoted). Each provides a different trade-off between readability
  and expressive power.
  The {{:http://www.yaml.org/spec/1.2/spec.html#id2786942:}Yaml spec section 7.3}
  has more details. *)

type layout_style = [
  | `Any
  | `Block
  | `Flow
] [@@deriving sexp]
(** Mappings and sequences can be rendered in two different ways:
  - [Flow] styles can be thought of as the natural extension of
    JSON to cover folding long content lines for readability, tagging nodes
    to control construction of native data structures, and using anchors and
    aliases to reuse constructed object instances.
  - [Block] styles employ indentation rather than indicators to denote structure.
    This results in a more human readable (though less compact) notation.
*)

type 'a res = ('a, Rresult.R.msg) Result.result
(** This library uses the {!Rresult.R.msg} conventions for returning
   errors rather than raising exceptions. *)

(** {2 Serialisers and deserialisers}
  Most simple uses of Yaml can use the JSON-compatible subset.
  If you really need Yaml-specific features such as aliases, then
  they are also available. *)

(** {3 JSON-compatible functions} *)

val of_string : string -> value res
(** [of_string s] parses [s] into a JSON {!value} representation, discarding
  any Yaml-specific information such as anchors or tags. *)

val of_string_exn : string -> value
(** [of_string_exn s] acts as {!of_string}, but raises {!Invalid_argument}
  if there is an error. *)

val to_string : ?len:int -> ?encoding:encoding -> ?scalar_style:scalar_style ->
  ?layout_style:layout_style -> value -> string res
(** [to_string v] converts the JSON value to a Yaml string representation.
   The [encoding], [scalar_style] and [layout_style] control the various
   output parameters.
   The current implementation uses a non-resizable internal string buffer of
   16KB, which can be increased via [len].  *)

val to_string_exn : ?len:int -> ?encoding:encoding -> ?scalar_style:scalar_style ->
  ?layout_style:layout_style -> value -> string
(** [to_string_exn v] acts as {!to_string}, but raises {!Invalid_argument} in
  if there is an error. *)

val pp : Format.formatter -> value -> unit
(** [pp ppf s] will output the Yaml value [s] to the formatter [ppf]. *)

(** {3 Yaml-specific functions} *)

val yaml_of_string : string -> yaml res
(** [yaml_of_string s] parses [s] into a Yaml {!yaml} representation,
  preserving Yaml-specific information such as anchors. *)

val yaml_to_string : ?encoding:encoding -> ?scalar_style:scalar_style ->
  ?layout_style:layout_style -> yaml -> string res
(** [yaml_to_string v] converts the Yaml value to a string representation.
   The [encoding], [scalar_style] and [layout_style] control the various
   output parameters.
   The current implementation uses a non-resizable internal string buffer of
   16KB, which can be increased via [len].  *)

(** {2 JSON/Yaml conversion functions} *)

val to_json : yaml -> value res
(** [to_json yaml] will convert the Yaml document into a simpler
  JSON representation, discarding any anchors or tags from the original.
  Returns an error if any aliases are used within the body of the Yaml input. *)

val of_json : value -> yaml res
(** [of_json j] converts the JSON representation into a Yaml representation. *)


(** Low-level event streaming interface for parsing and emitting YAML files.

   This module has a:
    - {!Stream.parser}, which takes an input stream of bytes and produces a sequence of parsing events.
    - {!Stream.emitter}, which takes a sequence of events and produces a stream of bytes.

  The processes of parsing and presenting are inverse to each other. Any sequence of events
  produced by parsing a well-formed YAML document should be acceptable by the Emitter,
  which should produce an equivalent document.  Similarly, any document produced by emitting a
  sequence of events should be acceptable for the Parser, which should produce an equivalent
  sequence of events. *)
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
      | Scalar of
          { anchor: string option
          ; tag: string option
          ; value: string
          ; plain_implicit: bool
          ; quoted_implicit: bool
          ; style: scalar_style }
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

  (** {3 Parsing functions} *)

  type parser
  (** [parser] tracks the state of generating {!Event.t} values. *)

  val parser : string -> (parser, [> Rresult.R.msg]) Result.result
  (** [parser ()] will allocate a fresh parser state. *)

  val do_parse : parser -> (Event.t * Event.pos) res
  (** [do_parse parser] will generate the next parsing event from an
      initialised parser.  *)

  (** {3 Serialisation functions} *)

  type emitter
  (** [emitter] tracks the state of generating {!Event.t} values for YAML output. *)

  val emitter : ?len:int -> unit -> emitter res
  (** [emitter ?len ()] will allocate a new emitter state. Due to a temporary
      limitation in the implementation, [len] decides how large the fixed size
      buffer that the output is written into is.  In the future, [len] will be
      redundant as the buffer will be dynamically allocated. *)

  val emitter_buf : emitter -> Bytes.t

  val emit : emitter -> Event.t -> unit res

  val document_start : ?implicit:bool -> emitter -> unit res

  val document_end : ?implicit:bool -> emitter -> unit res

  val scalar : ?plain_implicit:bool -> ?quoted_implicit:bool -> ?anchor:string ->
    ?tag:string -> ?style:scalar_style -> emitter -> string -> unit res

  val alias : emitter -> string -> unit res

  val stream_start : emitter -> encoding -> unit res

  val stream_end : emitter -> unit res

  val sequence_start : ?anchor:string -> ?tag:string -> ?implicit:bool -> ?style:layout_style -> emitter -> unit res

  val sequence_end : emitter -> unit res

  val mapping_start : ?anchor:string -> ?tag:string -> ?implicit:bool -> ?style:layout_style -> emitter -> unit res

  val mapping_end : emitter -> unit res

  val emitter_written : emitter -> int

  val get_version : unit -> int * int * int
  (** [library_version ()] returns the major, minor and patch version of the underlying libYAML implementation. *)

end
