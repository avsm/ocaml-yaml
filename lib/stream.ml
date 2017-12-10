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
open Rresult
open Types

module B = Yaml_ffi.M
module T = Yaml_types.M

type tag_directive = {
  handle: string;
  prefix: string;
} [@@deriving sexp]

let error_to_msg e =
  match e with
  | `None -> "No error"
  | `Memory -> "Reader error"
  | `Scanner -> "Scanner error"
  | `Parser -> "Parser error"
  | `Composer -> "Compose error"
  | `Writer -> "Writer error"
  | `Emitter -> "Emitter error"
  | `E i -> "Unknown error code " ^ (Int64.to_string i)

let scalar_style_of_ffi s : scalar_style =
  match s with
  | `Any -> `Any
  | `Plain -> `Plain
  | `Single_quoted -> `Single_quoted
  | `Double_quoted -> `Double_quoted
  | `Literal -> `Literal
  | `Folded -> `Folded
  | `E err -> raise (Invalid_argument ("invalid scalar style"^(Int64.to_string err)))

let layout_style_of_ffi s : layout_style =
  match s with
  | `Any -> `Any
  | `Block -> `Block
  | `Flow -> `Flow
  | `E err -> raise (Invalid_argument ("invalid mapping style"^(Int64.to_string err)))

let layout_style_of_ffi s : layout_style =
  match s with
  | `Any -> `Any
  | `Block -> `Block
  | `Flow -> `Flow
  | `E err -> raise (Invalid_argument ("invalid sequence style"^(Int64.to_string err)))

let encoding_of_ffi e : encoding =
  match e with
  | `Any -> `Any
  | `Utf16be -> `Utf16be
  | `Utf16le -> `Utf16le
  | `Utf8 -> `Utf8
  | `E err -> raise (Invalid_argument ("invalid encoding "^(Int64.to_string err)))

let tag_directive_of_ffi e =
  let open Ctypes in
  let handle = !@ (e |-> T.Tag_directive.handle) in
  let prefix = !@ (e |-> T.Tag_directive.prefix) in
  { handle; prefix }

let list_of_tag_directives tds =
  let open Ctypes in
  let module TEDT = T.Event.Document_start.Tag_directives in
  let hd = !@ (tds |-> TEDT.start) in
(* TODO not clear how to parse this as not a linked list *)
  let acc = [hd] in
  List.map tag_directive_of_ffi acc
 
let version_of_directive ~major ~minor =
  match major, minor with
  | 1,0 -> `V1_0
  | 1,1 -> `V1_1
  | _ -> raise (Invalid_argument (Printf.sprintf "Unsupported Yaml version %d.%d" major minor))

module Mark = struct
  type t = {
    index: int;
    line: int;
    column: int;
  } [@@deriving sexp]

  let of_ffi m =
    let open Ctypes in
    let int_field f = getf m f |> Unsigned.Size_t.to_int in
    let index = int_field T.Mark.index in
    let line = int_field T.Mark.line in
    let column = int_field T.Mark.column in
    { index; line; column }
end

module Event = struct
  type pos = {
    start_mark: Mark.t;
    end_mark: Mark.t;
  } [@@deriving sexp]

  type t =
   | Stream_start of { encoding: encoding }
   | Document_start of { version: version option; implicit: bool }
   | Document_end of { implicit: bool }
   | Mapping_start of { anchor: string option; tag: string option; implicit: bool; style: layout_style }
   | Mapping_end
   | Stream_end 
   | Scalar of { anchor: string option; tag: string option; value: string; plain_implicit: bool; quoted_implicit: bool; style: scalar_style }
   | Sequence_start of { anchor: string option; tag: string option; implicit: bool; style: layout_style }
   | Sequence_end
   | Alias of { anchor: string }
   | Nothing 
   [@@deriving sexp]

  let of_ffi e : t * pos =
    let open T.Event in
    let open Ctypes in
    let ty = getf e _type in
    let data = getf e data in
    let start_mark = getf e start_mark |> Mark.of_ffi in
    let end_mark = getf e end_mark |> Mark.of_ffi in
    let pos = { start_mark; end_mark } in
    let r = match ty with
    |`Stream_start ->
       let start = getf data Data.stream_start in
       let encoding = getf start Stream_start.encoding |> encoding_of_ffi in
       Stream_start { encoding }
    |`Document_start ->
       let ds = getf data Data.document_start in
       let version =
         let vd = getf ds Document_start.version_directive in
         match vd with
         |None -> None
         |Some vd -> let vd = !@ vd in
           let major = getf vd T.Version_directive.major in
           let minor = getf vd T.Version_directive.minor in
           Some (version_of_directive ~major ~minor) in
       let implicit = getf ds Document_start.implicit <> 0 in
       Document_start { version; implicit}
    |`Mapping_start ->
      let ms = getf data Data.mapping_start in
      let anchor = getf ms Mapping_start.anchor in
      let tag = getf ms Mapping_start.tag in
      let implicit = getf ms Mapping_start.implicit <> 0 in
      let style = getf ms Mapping_start.style |> layout_style_of_ffi in
      Mapping_start { anchor; tag; implicit; style }
    |`Scalar ->
      let s = getf data Data.scalar in
      let anchor = getf s Scalar.anchor in
      let tag = getf s Scalar.tag in
      let value = getf s Scalar.value in
      let plain_implicit = getf s Scalar.plain_implicit <> 0 in
      let quoted_implicit = getf s Scalar.quoted_implicit <> 0 in
      let style = getf s Scalar.style |> scalar_style_of_ffi in
      Scalar { anchor; tag; value; plain_implicit; quoted_implicit; style }
    |`Document_end ->
      let de = getf data Data.document_end in
      let implicit = getf de Document_end.implicit <> 0 in
      Document_end { implicit }
    |`Sequence_start ->
      let ss = getf data Data.sequence_start in
      let anchor = getf ss Sequence_start.anchor in
      let tag = getf ss Sequence_start.tag in
      let implicit = getf ss Sequence_start.implicit <> 0 in
      let style = getf ss Sequence_start.style |> layout_style_of_ffi in
      Sequence_start {anchor; tag; implicit; style}
    |`Sequence_end -> Sequence_end 
    |`Mapping_end -> Mapping_end 
    |`Stream_end -> Stream_end
    |`Alias ->
      let a = getf data Data.alias in
      let anchor = 
        match getf a Alias.anchor with
        | None -> raise (Invalid_argument "empty anchor alias")
        | Some a -> a in
      Alias { anchor }
    |`None -> Nothing
    |`E i -> raise (Invalid_argument ("Unexpected event, internal library error "^(Int64.to_string i)))
    in r, pos
    
end

let version = B.version
let get_version () =
  let major = Ctypes.(allocate int 0) in
  let minor = Ctypes.(allocate int 0) in
  let patch = Ctypes.(allocate int 0) in
  B.get_version major minor patch;
  let major = Ctypes.((!@) major) in
  let minor = Ctypes.((!@) minor) in
  let patch = Ctypes.((!@) patch) in
  major, minor, patch

type parser = {
  p: T.Parser.t Ctypes.structure Ctypes.ptr;
  event: T.Event.t Ctypes.structure Ctypes.ptr;
  buf: string;
}

let parser buf =
  let p = Ctypes.(allocate_n T.Parser.t ~count:1) in
  let event = Ctypes.(allocate_n T.Event.t ~count:1) in
  let r = B.parser_init p in
  let len = String.length buf |> Unsigned.Size_t.of_int in
  B.parser_set_input_string p buf len;
  match r with
  | 1 -> R.ok {buf; p;event}
  | _ -> R.error_msg "error initialising parser"

let do_parse {p;event} =
  let open Ctypes in
  let r = B.parser_parse p event in
  match r with
  | 1 -> Event.of_ffi (!@ event) |> R.ok
  | _ -> R.error_msg "error calling parser"

type emitter = {
  e: T.Emitter.t Ctypes.structure Ctypes.ptr;
  event: T.Event.t Ctypes.structure Ctypes.ptr;
  buf: Bytes.t;
  written: Unsigned.size_t Ctypes.ptr;
}

let emitter_written {written;_} = Ctypes.(!@ written) |> Unsigned.Size_t.to_int

let emitter ?(len=16386) () =
  let e = Ctypes.(allocate_n T.Emitter.t ~count:1) in
  let event = Ctypes.(allocate_n T.Event.t ~count:1) in
  let written = Ctypes.allocate_n Ctypes.size_t ~count:1 in
  let r = B.emitter_init e in
  let buf = Bytes.create len in
  let len = Bytes.length buf |> Unsigned.Size_t.of_int in
  B.emitter_set_output_string e (Ctypes.ocaml_bytes_start buf) len written;
  match r with
  | 1 -> R.ok {e;event;written; buf}
  | _ -> R.error_msg "error initialising emitter"

let emitter_buf {buf; written} =
  Ctypes.(!@ written) |> Unsigned.Size_t.to_int |>
  Bytes.sub buf 0

let check l a =
  match a with
  | 0 -> R.error_msg (l ^ " failed")
  | 1 -> R.ok ()
  | _ -> R.error_msg "unexpected return value"

let check_emit l {e;event} a =
  check l a >>= fun () ->
  check l @@ B.emitter_emit e event

let stream_start t encoding =
  check_emit "stream_start" t @@
  B.stream_start_event_init t.event (encoding :> T.Encoding.t)

let stream_end t =
  check_emit "stream_end" t @@ B.stream_end_event_init t.event

let document_start ?(implicit=true) t  =
  let open Ctypes in
  let ver = from_voidp T.Version_directive.t null in
  let tag = from_voidp T.Tag_directive.t null in
  check_emit "doc_start" t @@ B.document_start_event_init t.event ver tag tag implicit

let document_end ?(implicit=true) t =
  check_emit "doc_end" t @@ B.document_end_event_init t.event implicit 

let scalar ?(plain_implicit=true) ?(quoted_implicit=false) ?anchor ?tag ?(style=`Plain) t value =
  check_emit "scalar" t @@ B.scalar_event_init t.event anchor tag value (String.length value) plain_implicit quoted_implicit (style :> T.Scalar_style.t)

let sequence_start ?anchor ?tag ?(implicit=true) ?(style=`Block) t =
  check_emit "seq_start" t @@ B.sequence_start_event_init t.event anchor tag implicit (style :> T.Sequence_style.t)

let sequence_end t =
  check_emit "seq_end" t @@ B.sequence_end_event_init t.event

let mapping_start ?anchor ?tag ?(implicit=true) ?(style=`Block) t =
  check_emit "mapping_start" t @@ B.mapping_start_event_init t.event anchor tag implicit (style :> T.Mapping_style.t)

let mapping_end t =
  check_emit "mapping_end" t @@ B.mapping_end_event_init t.event

let alias t value =
  check_emit "alias" t @@ B.alias_event_init t.event value

let emit t =
  let open Event in
  function
  | Stream_start { encoding } -> stream_start t encoding
  | Document_start { version; implicit } -> document_start ~implicit t
  | Document_end { implicit } -> document_end ~implicit t
  | Mapping_start { anchor; tag; implicit; style } -> mapping_start ?anchor ?tag ~implicit ~style t
  | Mapping_end -> mapping_end t
  | Stream_end -> stream_end t
  | Scalar { anchor; tag; value; plain_implicit; quoted_implicit; style } -> scalar ?anchor ?tag ~plain_implicit ~quoted_implicit ~style t value
  | Sequence_start { anchor; tag; implicit; style } -> sequence_start ?anchor ?tag ~implicit ~style t
  | Sequence_end -> sequence_end t
  | Alias { anchor } -> alias t anchor
  | Nothing -> Ok ()

