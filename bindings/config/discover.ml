open Base
open Stdio
module C = Configurator

let write_sexp fn sexp =
  Out_channel.write_all fn ~data:(Sexp.to_string sexp)
(* osx pkg-config yaml is broken *)
let fix_cflags t = {t with C.Pkg_config.cflags="-I/usr/local/include"::t.C.Pkg_config.cflags}

let () =
  C.main ~name:"libyaml" (fun c ->
    let default : C.Pkg_config.package_conf =
      { libs   = ["-lyaml"]
      ; cflags = []
      }
    in
    let conf =
      match C.Pkg_config.get c with
      | None -> default
      | Some pc ->
        Option.value (C.Pkg_config.query pc ~package:"yaml-0.1") ~default
    in
    let conf = fix_cflags conf in
    write_sexp "yaml-cclib.sexp" [%sexp (conf.libs   : string list)];
    write_sexp "yaml-ccopt.sexp" [%sexp (conf.cflags : string list)];
    Out_channel.write_all "yaml-cclib" ~data:(String.concat conf.libs   ~sep:" ");
    Out_channel.write_all "yaml-ccopt" ~data:(String.concat conf.cflags ~sep:" "))
