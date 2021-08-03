open Rresult

type t = {
  v: Yaml_sexp.value
} [@@deriving sexp]

let v file =
  let open R.Infix in
  Bos.OS.File.read file >>= fun buf ->
  Yaml.yaml_of_string buf >>= fun v ->
  Yaml_sexp.sexp_of_yaml v |> fun s ->
  Sexplib.Sexp.to_string_hum s |> fun b ->
  Printf.printf "%s\n%!" b;
  Sexplib.Sexp.of_string b |> Yaml_sexp.yaml_of_sexp |> fun v' ->
  assert(v = v');
  Ok ()
