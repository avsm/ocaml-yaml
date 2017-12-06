open Rresult

let test () =
  let open R.Infix in
  Bos.OS.File.read (Fpath.v "cohttp.yml") >>= fun buf ->
  Yaml.of_string buf >>= fun v ->
  Printf.printf "%s\n%!" (Yaml.sexp_of_value v |> Sexplib.Sexp.to_string_hum);
  Ezjsonm.to_string (Ezjsonm.wrap v) |> fun b ->
  Printf.printf "%s\n%!" b;
  Yaml.to_string v >>= fun s ->
  Printf.printf "%s\n%!" s;
  Ok ()

let _ =
  match test () with
  | Ok _ -> ()
  | Error (`Msg m) ->
      prerr_endline m;
      exit 1
