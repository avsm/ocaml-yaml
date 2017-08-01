module Types = Yaml_bindings.Ffi_bindings.Types(Ffi_generated_types)
module B = Yaml_bindings.Ffi_bindings.Bindings(Ffi_generated)

let version = B.version
let get_version () =
  let major = Ctypes.(allocate int 0) in
  let minor = Ctypes.(allocate int 0) in
  let patch = Ctypes.(allocate int 0) in
  B.get_version major minor patch;
  let major = Ctypes.((!@) major) in
  let minor = Ctypes.((!@) minor) in
  let patch = Ctypes.((!@) patch) in
  major, minor, patch
