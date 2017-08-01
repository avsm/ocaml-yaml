module M(T:module type of Yaml_types.M)(F: Cstubs.FOREIGN) =
struct
  let foreign = F.foreign
  type 'a typ = 'a Ctypes.structure Ctypes.typ

  module C = struct
    include Ctypes
    let (@->)         = F.(@->)
    let returning     = F.returning
    let foreign       = F.foreign
    let foreign_value = F.foreign_value
  end

  module Version_directive = struct
    type t
    let t : t typ = C.structure "yaml_version_directive_t"
    let major = C.(field t "major" int)
    let minor = C.(field t "minor" int)
    let () = C.seal t
  end

  let yaml_char_t = C.uchar

  module Tag_directive = struct
    type t
    let t : t typ = C.structure "yaml_tag_directive_t"
    let handle = C.(field t "handle" (ptr yaml_char_t))
    let prefix = C.(field t "prefix" (ptr yaml_char_t))
    let () = C.seal t
  end

  module Mark = struct
    type t
    let t : t typ = C.structure "yaml_mark_t"
    let index = C.(field t "index" size_t)
    let line = C.(field t "line" size_t)
    let column = C.(field t "column" size_t)
    let () = C.seal t
  end

  module Token = struct
    type t
    let t : t typ = C.structure "yaml_token_t"
    let _type = C.(field t "type" T.token_type)
    let () = C.seal t
  end

  let version =
    foreign "yaml_get_version_string" C.(void @-> returning string)

  let get_version =
    foreign "yaml_get_version" C.(ptr int @-> ptr int @-> ptr int @-> returning void)
end
