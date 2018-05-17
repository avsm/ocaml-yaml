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

module T = Yaml_types.M

module M(F: Ctypes.FOREIGN) =
struct
  let foreign = F.foreign

  module C = struct
    include Ctypes
    let (@->)         = F.(@->)
    let returning     = F.returning
  end

  let version =
    foreign "yaml_get_version_string" C.(void @-> returning string)

  let get_version =
    foreign "yaml_get_version" C.(ptr int @-> ptr int @-> ptr int @-> returning void)

  let token_delete =
    foreign "yaml_token_delete" C.(ptr T.Token.t @-> returning void)

  let parser_init =
    foreign "yaml_parser_initialize" C.(ptr T.Parser.t @-> returning int)

  let parser_delete =
    foreign "yaml_parser_delete" C.(ptr T.Parser.t @-> returning void)

  let parser_set_input_string =
    foreign "yaml_parser_set_input_string" C.(ptr T.Parser.t @-> string @-> size_t @-> returning void)

  let parser_parse =
    foreign "yaml_parser_parse" C.(ptr T.Parser.t @-> ptr T.Event.t @-> returning int)

  let emitter_init =
    foreign "yaml_emitter_initialize" C.(ptr T.Emitter.t @-> returning int)

  let emitter_delete =
    foreign "yaml_emitter_delete" C.(ptr T.Emitter.t @-> returning void)

  let emitter_set_output_string =
    foreign "yaml_emitter_set_output_string" C.(ptr T.Emitter.t @-> ocaml_bytes @-> size_t @-> ptr size_t @-> returning void)

(* TODO static funptr 
  let write_handler = C.(ptr void @-> ptr uchar @-> size_t @-> returning int)

  let emitter_set_output =
    foreign "yaml_emitter_set_output" C.(ptr T.Emitter.t @-> (static_funptr write_handler) @-> ptr void @-> returning void)
*)

  let emitter_set_encoding =
    foreign "yaml_emitter_set_encoding" C.(ptr T.Emitter.t @-> T.encoding_t @-> returning void)

  let emitter_set_canonical =
    foreign "yaml_emitter_set_canonical" C.(ptr T.Emitter.t @-> bool @-> returning void)

  let emitter_set_indent =
    foreign "yaml_emitter_set_indent" C.(ptr T.Emitter.t @-> int @-> returning void)

  let emitter_set_width =
    foreign "yaml_emitter_set_width" C.(ptr T.Emitter.t @-> int @-> returning void)

  let emitter_set_unicode =
    foreign "yaml_emitter_set_unicode" C.(ptr T.Emitter.t @-> bool @-> returning void)

  let emitter_flush =
    foreign "yaml_emitter_flush" C.(ptr T.Emitter.t @-> returning int)

(* TODO bind break_t
  let emitter_set_break =
    foreign "yaml_emitter_set_break" C.(ptr T.Emitter.t @-> T.break_t @-> returning void) 
*)

  let emitter_emit =
     foreign "yaml_emitter_emit" C.(ptr T.Emitter.t @-> ptr T.Event.t @-> returning int)

  let stream_start_event_init =
     foreign "yaml_stream_start_event_initialize" C.(ptr T.Event.t @-> T.encoding_t @-> returning int)

  let stream_end_event_init =
     foreign "yaml_stream_end_event_initialize" C.(ptr T.Event.t @-> returning int)
 
  let document_start_event_init =
     foreign "yaml_document_start_event_initialize" C.(ptr T.Event.t @-> ptr T.Version_directive.t @-> ptr T.Tag_directive.t @-> ptr T.Tag_directive.t @-> bool @-> returning int)

  let document_end_event_init =
     foreign "yaml_document_end_event_initialize" C.(ptr T.Event.t @-> bool @-> returning int)

  let alias_event_init =
     foreign "yaml_alias_event_initialize" C.(ptr T.Event.t @-> string @-> returning int)

  let scalar_event_init =
     foreign "yaml_scalar_event_initialize" C.(ptr T.Event.t @-> string_opt @-> string_opt @-> string @-> int @-> bool @-> bool @-> T.scalar_style_t @-> returning int)

  let sequence_start_event_init =
     foreign "yaml_sequence_start_event_initialize" C.(ptr T.Event.t @-> string_opt @-> string_opt @-> bool @-> T.sequence_style_t @-> returning int)

  let sequence_end_event_init =
     foreign "yaml_sequence_end_event_initialize" C.(ptr T.Event.t @-> returning int)

  let mapping_start_event_init =
     foreign "yaml_mapping_start_event_initialize" C.(ptr T.Event.t @-> string_opt @-> string_opt @-> bool @-> T.mapping_style_t @-> returning int)

  let mapping_end_event_init =
     foreign "yaml_mapping_end_event_initialize" C.(ptr T.Event.t @-> returning int)
end
