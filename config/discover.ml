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
    let within_spaces = ref false in
    String.iter (fun c ->
        if c = ' ' then begin
          if not !within_spaces then begin
            within_spaces := true;
            output_char fout '\n'
          end
        end else begin
          within_spaces := false;
          output_char fout c
        end
      ) cflags;
    close_out fout
    )
