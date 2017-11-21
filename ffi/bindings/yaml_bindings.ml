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

module M(F: Cstubs.FOREIGN) =
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
end
