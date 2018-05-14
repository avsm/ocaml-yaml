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

module Encoding : sig
  type t = [ `Any | `E of int64 | `Utf16be | `Utf16le | `Utf8 ] [@@deriving sexp]
end

module Error : sig
  type t = [ `None | `Memory | `Reader | `Scanner | `Parser
           | `Composer | `Writer | `Emitter | `E of int64 ] [@@deriving sexp]
end

module Scalar_style : sig
  type t = [ `Any | `Plain | `Single_quoted | `Double_quoted
           | `Literal | `Folded | `E of int64 ] [@@deriving sexp]
end

module Sequence_style : sig
  type t = [ `Any | `Block | `Flow | `E of int64 ] [@@deriving sexp]
end

module Mapping_style : sig
  type t = [ `Any | `Block | `Flow | `E of int64 ] [@@deriving sexp]
end

module Token_type : sig
  type t = [ `None | `Stream_start | `Stream_end | `Version_directive
           | `Tag_directive | `Document_start | `Document_end
           | `Block_sequence_start | `Block_mapping_start | `Block_end
           | `Flow_sequence_start | `Flow_sequence_end | `Flow_mapping_start
           | `Flow_mapping_end | `Block_entry | `Flow_entry | `Key
           | `Value | `Alias | `Anchor | `Tag | `Scalar | `E of int64 ] [@@deriving sexp]
end

module Event_type : sig
  type t = [ `None | `Stream_start | `Stream_end | `Document_start
           | `Document_end | `Alias | `Scalar | `Sequence_start
           | `Sequence_end | `Mapping_start | `Mapping_end | `E of int64 ] [@@deriving sexp]
end
 
module M(F : Ctypes.TYPE) : sig
  val encoding_t : Encoding.t F.typ
  val error_t : Error.t F.typ
  val scalar_style_t : Scalar_style.t F.typ
  val sequence_style_t : Sequence_style.t F.typ
  val mapping_style_t : Mapping_style.t F.typ
  val token_type_t : Token_type.t F.typ
  val event_type_t : Event_type.t F.typ

  type 'a typ = 'a Ctypes.structure F.typ
  type 'a utyp = 'a Ctypes.union F.typ
  type ('a,'b) field = ('b, 'a Ctypes.structure) F.field
  type ('a,'b) ufield = ('b, 'a Ctypes.union) F.field

  module Version_directive : sig
    type t
    val t : t typ
    val major : (t, int) field
    val minor : (t, int) field
  end

  module Tag_directive : sig
    type t
    val t : t typ
    val handle : (t, string) field
    val prefix : (t, string) field
  end

  module Mark : sig
    type t
    val t : t typ
    val index: (t, Unsigned.size_t) field
    val line: (t, Unsigned.size_t) field
    val column: (t, Unsigned.size_t) field
  end

  module Token : sig
    module Stream_start : sig
      type t
      val t : t typ
      val encoding : (t, Encoding.t) field
    end
    module Alias : sig
      type t
      val t : t typ
    end
    module Anchor : sig
      type t
      val t : t typ
    end
    module Scalar : sig
      type t
      val t : t typ
    end
    module Version : sig
      type t
      val t : t typ
    end
    module Data : sig
      type t
      val t : t utyp
      val stream_start : (t, Stream_start.t Ctypes.structure) ufield
    end
    type t
    val t : t typ
    val _type : (Token_type.t, t Ctypes.structure) F.field
    val data : (Data.t Ctypes.union, t Ctypes.structure) F.field
  end

  module Event : sig
    module Stream_start : sig
      type t
      val encoding: (t, Encoding.t) field
    end
    module Mapping_start : sig
       type t
       val t : t typ
       val anchor : (t, string option) field
       val tag : (t, string option) field
       val implicit : (t, int) field
       val style : (t, Mapping_style.t) field
    end
    module Scalar : sig
      type t
       val t : t typ
       val anchor : (t, string option) field
       val tag : (t, string option) field
       val value : (t, string) field
       val length : (t, Unsigned.size_t) field
       val plain_implicit : (t, int) field
       val quoted_implicit : (t, int) field
       val style : (t, Scalar_style.t) field
    end
    module Document_start : sig
      module Tag_directives : sig
        type t
        val t : t typ
        val start : (t, Tag_directive.t Ctypes.structure Ctypes.ptr) field
        val _end : (t, Tag_directive.t Ctypes.structure Ctypes.ptr) field
      end
      type t
      val version_directive: (t, Version_directive.t Ctypes.structure Ctypes.ptr option) field
      val tag_directives : (t, Tag_directives.t Ctypes.structure) field
      val implicit: (t, int) field
    end
    module Document_end : sig
      type t
      val t : t typ
      val implicit : (t, int) field
    end 
    module Sequence_start : sig
      type t
      val t : t typ
      val anchor : (t, string option) field
      val tag : (t, string option) field
      val implicit : (t, int) field
      val style : (t, Sequence_style.t) field
    end
    module Alias : sig
      type t
      val t : t typ
      val anchor : (t, string option) field
    end
    module Data : sig
      type t
      val stream_start : (t, Stream_start.t Ctypes.structure) ufield
      val document_start : (t, Document_start.t Ctypes.structure) ufield
      val document_end : (t, Document_end.t Ctypes.structure) ufield
      val mapping_start : (t, Mapping_start.t Ctypes.structure) ufield
      val scalar : (t, Scalar.t Ctypes.structure) ufield
      val alias : (t, Alias.t Ctypes.structure) ufield
      val sequence_start : (t, Sequence_start.t Ctypes.structure) ufield
    end
    type t
    val t : t typ
    val _type : (t, Event_type.t) field
    val data : (t, Data.t Ctypes.union) field
    val start_mark : (t, Mark.t Ctypes.structure) field
    val end_mark : (t, Mark.t Ctypes.structure) field
  end

  module Parser : sig
    type t
    val t : t typ
  end

  module Emitter : sig
    type t
    val t : t typ
  end
end
