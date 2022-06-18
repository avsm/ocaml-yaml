module C = Configurator.V1

let ocamlopt_lines c =
  let cflags =
    try C.ocaml_config_var_exn c "ocamlopt_cflags"
    with _ -> "-O2 -fno-strict-aliasing -fwrapv"
  in
  C.Flags.extract_blank_separated_words cflags

let ppc64_lines c =
  let arch = C.ocaml_config_var_exn c "architecture" in
  let model = C.ocaml_config_var_exn c "model" in
  match (arch, model) with
  | "power", "ppc64le" -> [ "-mcmodel=small" ]
  | _ -> []

let dll_lines c =
  let ccomp_type = C.ocaml_config_var_exn c "ccomp_type" in
  match ccomp_type with "msvc" -> [ "-DYAML_DECLARE_EXPORT" ] | _ -> []

let () =
  let cstubs = ref "" in
  let args = Arg.[ ("-cstubs", Set_string cstubs, "cstubs loc") ] in
  C.main ~args ~name:"yaml" (fun c ->
      let vendor_cflags =
        Printf.sprintf "-I%s" (Unix.realpath (Filename.dirname !cstubs))
      in
      let ffi_cflags =
        let vendor_headers =
          Printf.sprintf "-I%s" (Unix.realpath "../vendor/headers")
        in
        (vendor_headers :: ocamlopt_lines c) @ ppc64_lines c
      in
      C.Flags.write_sexp "ffi-cflags.sexp" ffi_cflags;
      C.Flags.write_sexp "vendor-cflags.sexp" [ vendor_cflags ])
