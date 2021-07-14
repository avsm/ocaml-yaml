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
  | `A of yaml list
  | `O of (scalar * yaml) list
] [@@deriving sexp]

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

type version = [ `V1_0 | `V1_1 ] [@@deriving sexp]

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
