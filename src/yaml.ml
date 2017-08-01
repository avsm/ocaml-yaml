module B = Yaml_ffi.M

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
