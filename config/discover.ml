module C = Configurator.V1

let ocamlopt_lines c =
  let cflags = C.ocaml_config_var_exn c "ocamlopt_cflags" in
  C.Flags.extract_blank_separated_words cflags

let ppc64_lines c =
  let arch = C.ocaml_config_var_exn c "architecture" in
  let model = C.ocaml_config_var_exn c "model" in
  match arch, model with
  | "power", "ppc64le" -> ["-mcmodel=small"]
  | _ -> []

let () =
  C.main ~name:"yaml" (fun c ->
    let lines = ocamlopt_lines c @ ppc64_lines c in
    C.Flags.write_lines "cflags" lines
  )
