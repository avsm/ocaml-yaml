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
