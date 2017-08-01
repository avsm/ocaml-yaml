module Ffi_bindings = Yaml_bindings.Ffi_bindings

let prefix = "yaml_stub"

let prologue = "
#include <yaml.h>
"

let () =
  print_endline prologue;
  Cstubs.Types.write_c Format.std_formatter (module Ffi_bindings.Types)
