open Rresult

let v file =
  let open R.Infix in
  Bos.OS.File.read file >>= fun buf ->
  Yaml.yaml_of_string buf >>= fun v ->
  Yaml.to_json v >>= fun json ->
  Ezjsonm.to_string (Ezjsonm.wrap json) |> fun b ->
  Printf.printf "%s\n%!" b;
  Yaml.yaml_to_string v >>= fun s ->
  Printf.printf "%s\n%!" s;
  Ok ()
