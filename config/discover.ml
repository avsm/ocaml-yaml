module C = Configurator

let () =
  C.main ~name:"yaml" (fun c ->
    let cflags = C.ocaml_config_var_exn c "ocamlopt_cflags" in
    let arch = C.ocaml_config_var_exn c "architecture" in
    let model = C.ocaml_config_var_exn c "model" in
    let cflags =
      match arch,model with
      |"power","ppc64le" -> cflags ^ " -mcmodel=small"
      |_ -> cflags in
    let fout = open_out "cflags" in
    String.iter (fun c ->
      let c = if c = ' ' then '\n' else c in
      output_char fout c
    ) cflags;
    close_out fout
  )
