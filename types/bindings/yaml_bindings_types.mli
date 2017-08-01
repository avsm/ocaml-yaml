module Encoding : sig
  type t = [ `Any | `E of int64 | `Utf16be | `Utf16le | `Utf8 ]
end

module Error : sig
  type t = [ `None | `Memory | `Reader | `Scanner | `Parser
           | `Composer | `Writer | `Emitter | `E of int64 ]
end

module Scalar_style : sig
  type t = [ `Any | `Plain | `Single_quoted | `Double_quoted
           | `Literal | `Folded | `E of int64 ]
end

module Sequence_style : sig
  type t = [ `Any | `Block | `Flow | `E of int64 ]
end

module Mapping_style : sig
  type t = [ `Any | `Block | `Flow | `E of int64 ]
end

module Token_type : sig
  type t = [ `None | `Stream_start | `Stream_end | `Version_directive
           | `Tag_directive | `Document_start | `Document_end
           | `Block_sequence_start | `Block_mapping_start | `Block_end
           | `Flow_sequence_start | `Flow_sequence_end | `Flow_mapping_start
           | `Flow_mapping_end | `Block_entry | `Flow_entry | `Key
           | `Value | `Alias | `Anchor | `Tag | `Scalar | `E of int64 ]
end

module M(F : Cstubs.Types.TYPE) : sig
  val encoding : Encoding.t F.typ
  val error : Error.t F.typ
  val scalar_style : Scalar_style.t F.typ
  val sequence_style : Sequence_style.t F.typ
  val mapping_style : Mapping_style.t F.typ
  val token_type : Token_type.t F.typ
end
