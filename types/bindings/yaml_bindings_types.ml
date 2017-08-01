module M(F : Cstubs.Types.TYPE) =
struct

  let enum label typedef vals =
     F.enum ~typedef:true ~unexpected:(fun i -> `E i) typedef
     (List.map (fun (a,b) -> a, (F.constant ("YAML_"^b^"_"^label) F.int64_t)) vals)

  module Encoding = struct
    type t = [ `Any | `E of int64 | `Utf16be | `Utf16le | `Utf8 ]
    let t : t F.typ = enum "ENCODING" "yaml_encoding_t" [
      `Any,"ANY"; `Utf8,"UTF8"; `Utf16le,"UTF16LE"; `Utf16be,"UTF16BE" ]
  end

  module Error_type = struct
    type t = [ `None | `Memory | `Reader | `Scanner | `Parser 
             | `Composer | `Writer | `Emitter | `E of int64 ]
    let t : t F.typ = enum "ERROR" "yaml_error_type_t" [
      `None,"NO"; `Memory,"MEMORY"; `Reader,"READER"; `Scanner,"SCANNER";
      `Parser,"PARSER"; `Composer,"COMPOSER"; `Writer,"WRITER";
      `Emitter,"EMITTER" ]
  end

  module Scalar_style = struct
    type t = [ `Any | `Plain | `Single_quoted | `Double_quoted
             | `Literal | `Folded | `E of int64 ]
    let t : t F.typ = enum "SCALAR_STYLE" "yaml_scalar_style_t" [
       `Any,"ANY"; `Plain,"PLAIN"; `Single_quoted,"SINGLE_QUOTED";
       `Double_quoted,"DOUBLE_QUOTED"; `Literal,"LITERAL"; `Folded,"FOLDED" ]
  end

  module Sequence_style = struct
    type t = [ `Any | `Block | `Flow | `E of int64 ]
    let t : t F.typ = enum "SEQUENCE_STYLE" "yaml_sequence_style_t" [
      `Any,"ANY"; `Block,"BLOCK"; `Flow,"FLOW" ]
  end

  module Mapping_style = struct
    type t = [ `Any | `Block | `Flow | `E of int64 ]
    let t : t F.typ = enum "MAPPING_STYLE" "yaml_mapping_style_t" [
      `Any,"ANY"; `Block,"BLOCK"; `Flow,"FLOW" ]
  end

  module Token_type = struct
    type t = [ `None | `Stream_start | `Stream_end | `Version_directive
             | `Tag_directive | `Document_start | `Document_end
             | `Block_sequence_start | `Block_mapping_start | `Block_end
             | `Flow_sequence_start | `Flow_sequence_end | `Flow_mapping_start
             | `Flow_mapping_end | `Block_entry | `Flow_entry | `Key
             | `Value | `Alias | `Anchor | `Tag | `Scalar | `E of int64 ]
  
    let t : t F.typ = enum "TOKEN" "yaml_token_type_t" [
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
    
  end
end
