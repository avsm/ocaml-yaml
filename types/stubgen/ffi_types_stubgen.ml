let prefix = "yaml_stub"

let prologue = "
#include <yaml.h>
"

let () =
  print_endline prologue;
  Cstubs.Types.write_c Format.std_formatter (module Yaml_bindings_types.M)
