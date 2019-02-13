module C = Configurator.V1

let ocamlopt_lines c =
  let cflags =
    try C.ocaml_config_var_exn c "ocamlopt_cflags"
    with _ -> "-O2 -fno-strict-aliasing -fwrapv" in
  C.Flags.extract_blank_separated_words cflags

let ppc64_lines c =
  let arch = C.ocaml_config_var_exn c "architecture" in
  let model = C.ocaml_config_var_exn c "model" in
  match arch, model with
  | "power", "ppc64le" -> ["-mcmodel=small"]
  | _ -> []

let () =
  let cstubs = ref "" in
  let args = Arg.["-cstubs",Set_string cstubs,"cstubs loc"] in
  C.main ~args ~name:"yaml" (fun c ->
    let cstubs_cflags = Printf.sprintf "-I%s" (Filename.dirname !cstubs) in
    let lines = ocamlopt_lines c @ ppc64_lines c in
    C.Flags.write_lines "cflags" lines;
    C.Flags.write_lines "ctypes-cflags" [cstubs_cflags]
  )
