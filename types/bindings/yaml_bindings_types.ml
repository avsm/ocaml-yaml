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

module Encoding = struct
  type t = [ `Any | `E of int64 | `Utf16be | `Utf16le | `Utf8 ] [@@deriving sexp]
end

module Error = struct
  type t = [ `None | `Memory | `Reader | `Scanner | `Parser 
           | `Composer | `Writer | `Emitter | `E of int64 ] [@@deriving sexp]
end

module Scalar_style = struct
  type t = [ `Any | `Plain | `Single_quoted | `Double_quoted
           | `Literal | `Folded | `E of int64 ] [@@deriving sexp]
end

module Sequence_style = struct
  type t = [ `Any | `Block | `Flow | `E of int64 ] [@@deriving sexp]
end

module Mapping_style = struct
  type t = [ `Any | `Block | `Flow | `E of int64 ] [@@deriving sexp]
end

module Token_type = struct
  type t = [ `None | `Stream_start | `Stream_end | `Version_directive
           | `Tag_directive | `Document_start | `Document_end
           | `Block_sequence_start | `Block_mapping_start | `Block_end
           | `Flow_sequence_start | `Flow_sequence_end | `Flow_mapping_start
           | `Flow_mapping_end | `Block_entry | `Flow_entry | `Key
           | `Value | `Alias | `Anchor | `Tag | `Scalar | `E of int64 ] [@@deriving sexp]
end

module Event_type = struct
  type t = [ `None | `Stream_start | `Stream_end | `Document_start
           | `Document_end | `Alias | `Scalar | `Sequence_start
           | `Sequence_end | `Mapping_start | `Mapping_end | `E of int64 ] [@@deriving sexp]
end
 
module M(F : Ctypes.TYPE) =
struct

  let yaml_char_t = F.uchar

  let enum label typedef vals =
     F.enum ~typedef:true ~unexpected:(fun i -> `E i) typedef
     (List.map (fun (a,b) -> a, (F.constant ("YAML_"^b^"_"^label) F.int64_t)) vals)

  let encoding_t : Encoding.t F.typ =
    enum "ENCODING" "yaml_encoding_t" [
      `Any,"ANY"; `Utf8,"UTF8"; `Utf16le,"UTF16LE"; `Utf16be,"UTF16BE" ]

  let error_t : Error.t F.typ =
    enum "ERROR" "yaml_error_type_t" [
      `None,"NO"; `Memory,"MEMORY"; `Reader,"READER"; `Scanner,"SCANNER";
      `Parser,"PARSER"; `Composer,"COMPOSER"; `Writer,"WRITER";
      `Emitter,"EMITTER" ]

  let scalar_style_t : Scalar_style.t F.typ =
    enum "SCALAR_STYLE" "yaml_scalar_style_t" [
       `Any,"ANY"; `Plain,"PLAIN"; `Single_quoted,"SINGLE_QUOTED";
       `Double_quoted,"DOUBLE_QUOTED"; `Literal,"LITERAL"; `Folded,"FOLDED" ]

  let sequence_style_t : Sequence_style.t F.typ =
    enum "SEQUENCE_STYLE" "yaml_sequence_style_t" [
      `Any,"ANY"; `Block,"BLOCK"; `Flow,"FLOW" ]

  let mapping_style_t : Mapping_style.t F.typ =
    enum "MAPPING_STYLE" "yaml_mapping_style_t" [
      `Any,"ANY"; `Block,"BLOCK"; `Flow,"FLOW" ]

  let token_type_t : Token_type.t F.typ = enum "TOKEN" "yaml_token_type_t" [
      `None,"NO"; `Stream_start,"STREAM_START"; `Stream_end,"STREAM_END";
      `Version_directive,"VERSION_DIRECTIVE"; `Tag_directive,"TAG_DIRECTIVE";
      `Document_start,"DOCUMENT_START"; `Document_end,"DOCUMENT_END";
      `Block_sequence_start,"BLOCK_SEQUENCE_START";
      `Block_mapping_start,"BLOCK_MAPPING_START";
      `Block_end,"BLOCK_END"; `Flow_sequence_start,"FLOW_SEQUENCE_START";
      `Flow_sequence_end,"FLOW_SEQUENCE_END"; `Flow_mapping_start,"FLOW_MAPPING_START";
      `Flow_mapping_end,"FLOW_MAPPING_END"; `Block_entry,"BLOCK_ENTRY";
      `Flow_entry,"FLOW_ENTRY"; `Key,"KEY"; `Value,"VALUE"; `Alias,"ALIAS";
      `Tag,"TAG"; `Scalar,"SCALAR" ]

  let event_type_t : Event_type.t F.typ = enum "EVENT" "yaml_event_type_t" [
      `None,"NO"; `Stream_start,"STREAM_START";`Stream_end,"STREAM_END";
      `Document_start,"DOCUMENT_START";`Document_end,"DOCUMENT_END";
      `Alias,"ALIAS";`Scalar,"SCALAR";`Sequence_start,"SEQUENCE_START";
      `Sequence_end,"SEQUENCE_END"; `Mapping_start,"MAPPING_START";
      `Mapping_end,"MAPPING_END" ]

  type 'a typ = 'a Ctypes.structure F.typ
  type 'a utyp = 'a Ctypes.union F.typ
  type ('a,'b) field = ('b, 'a Ctypes.structure) F.field
  type ('a,'b) ufield = ('b, 'a Ctypes.union) F.field

  module Version_directive = struct
    type t
    let t : t typ = F.structure "yaml_version_directive_s"
    let major = F.(field t "major" int)
    let minor = F.(field t "minor" int)
    let () = F.seal t
  end

  module Tag_directive = struct
    type t
    let t : t typ = F.structure "yaml_tag_directive_s"
    let handle = F.(field t "handle" string)
    let prefix = F.(field t "prefix" string)
    let () = F.seal t
  end

  module Mark = struct
    type t
    let t : t typ = F.structure "yaml_mark_s"
    let index = F.(field t "index" size_t)
    let line = F.(field t "line" size_t)
    let column = F.(field t "column" size_t)
    let () = F.seal t
  end

  module Token = struct
    module Stream_start = struct (* YAML_STREAM_START_TOKEN *)
      type t
      let t : t typ = F.(structure "stream_start_s")
      let encoding = F.(field t "encoding" encoding_t)
      let () = F.seal t
     
    end
    module Alias = struct (* YAML_ALIAS_TOKEN *)
      type t
      let t : t typ = F.structure "alias_s"
      let value = F.(field t "value" (ptr yaml_char_t))
      let () = F.seal t
    end

    module Anchor = struct (* YAML_ANCHOR_TOKEN *)
      type t
      let t : t typ = F.structure "anchor_s"
      let value = F.(field t "value" (ptr yaml_char_t))
      let () = F.seal t
    end

    module Scalar = struct (* YAML_SCALAR_TOKEN *)
      type t
      let t : t typ = F.structure "scalar_s"
      let value = F.(field t "value" (ptr yaml_char_t))
      let length = F.(field t "length" size_t)
      let style = F.(field t "style" scalar_style_t)
      let () = F.seal t
    end

    module Version = struct (* YAML_VERSION_DIRECTIVE_TOKEN *)
      type t
      let t : t typ = F.structure "version_directive_s"
      let value = F.(field t "major" int)
      let length = F.(field t "minor" int)
      let () = F.seal t
    end

    module Data = struct (* Union *)
      type t
      let t : t utyp = F.union "data_u"
      let stream_start = F.(field t "stream_start" Stream_start.t)
      let alias = F.(field t "alias" Alias.t)
      let anchor = F.(field t "anchor" Anchor.t)
      let scalar = F.(field t "scalar" Scalar.t)
      let version = F.(field t "version_directive" Version_directive.t)
      let () = F.seal t
    end

    type t
    let t : t typ = F.structure "yaml_token_s"
    let _type = F.(field t "type" token_type_t)
    let data = F.(field t "data" Data.t)
    let start_mark = F.(field t "start_mark" Mark.t)
    let end_mark = F.(field t "end_mark" Mark.t)
    let () = F.seal t
  end

  module Event = struct
    module Stream_start = struct (* YAML_STREAM_START_EVENT *)
      type t
      let t : t typ = F.(structure "event_stream_start_s")
      let encoding = F.(field t "encoding" encoding_t)
      let () = F.seal t
    end
    module Document_start = struct
      module Tag_directives = struct
        type t
        let t : t typ = F.(structure "event_tag_directives_s")
        let start = F.(field t "start" (ptr Tag_directive.t))
        let _end = F.(field t "end" (ptr Tag_directive.t))
        let () = F.seal t
      end
      type t
      let t : t typ = F.(structure "event_document_start_s")
      let version_directive = F.(field t "version_directive" (ptr_opt Version_directive.t))
      let tag_directives = F.(field t "tag_directives" Tag_directives.t)
      let implicit = F.(field t "implicit" int)
      let () = F.seal t
    end
    module Document_end = struct
      type t
      let t : t typ = F.(structure "event_document_end_s")
      let implicit = F.(field t "implicit" int)
      let () = F.seal t
    end
    module Alias = struct
      type t
      let t : t typ = F.(structure "event_alias_s")
      let anchor = F.(field t "anchor" string_opt)
      let () = F.seal t
    end
    module Scalar = struct
      type t
      let t : t typ = F.(structure "event_scalar_s")
      let anchor = F.(field t "anchor" string_opt)
      let tag = F.(field t "tag" string_opt)
      let value = F.(field t "value" string)
      let length = F.(field t "length" size_t)
      let plain_implicit = F.(field t "plain_implicit" int)
      let quoted_implicit = F.(field t "quoted_implicit" int)
      let style = F.(field t "style" scalar_style_t)
      let () = F.seal t
    end
    module Sequence_start = struct
      type t
      let t : t typ = F.(structure "event_sequence_start_s")
      let anchor = F.(field t "anchor" string_opt)
      let tag = F.(field t "tag" string_opt)
      let implicit = F.(field t "implicit" int)
      let style = F.(field t "style" sequence_style_t)
      let () = F.seal t
    end
    module Mapping_start = struct
      type t
      let t : t typ = F.(structure "event_mapping_start_s")
      let anchor = F.(field t "anchor" string_opt)
      let tag = F.(field t "tag" string_opt)
      let implicit = F.(field t "implicit" int)
      let style = F.(field t "style" mapping_style_t)
      let () = F.seal t
    end
    module Data = struct (* Union *)
      type t
      let t : t utyp = F.union "event_data_u"
      let stream_start = F.(field t "stream_start" Stream_start.t)
      let document_start = F.(field t "document_start" Document_start.t)
      let document_end = F.(field t "document_end" Document_end.t)	
      let alias = F.(field t "alias" Alias.t)
      let scalar = F.(field t "scalar" Scalar.t)
      let sequence_start = F.(field t "sequence_start" Sequence_start.t)
      let mapping_start = F.(field t "mapping_start" Mapping_start.t)
      let () = F.seal t
    end

    type t
    let t : t typ = F.structure "yaml_event_s"
    let _type = F.(field t "type" event_type_t)
    let data = F.(field t "data" Data.t)
    let start_mark = F.(field t "start_mark" Mark.t)
    let end_mark = F.(field t "end_mark" Mark.t)
    let () = F.seal t
  end

  module Parser = struct
    type t
    let t : t typ = F.structure "yaml_parser_s"
    (* TODO *)
    let error = F.(field t "error" error_t)
    let () = F.seal t
  end

  module Emitter = struct
    type t
    let t : t typ = F.structure "yaml_emitter_s"
    (* TODO *)
    let () = F.seal t
  end
end
