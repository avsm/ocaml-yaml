module T = Yaml_types.M
open Rresult

let pp_event e pos =
  print_endline (Sexplib.Sexp.to_string_hum (Yaml.Stream.Event.sexp_of_t e)) 

let v file =
  let open R.Infix in
  Bos.OS.File.read file >>= fun buf ->
  Yaml.Stream.parser buf >>= fun t ->
  let rec iter_until_done fn =
    Yaml.Stream.do_parse t >>= fun (e, pos) ->
    match e with 
    | Yaml.Stream.Event.Nothing -> R.ok ()
    | event -> fn event pos; iter_until_done fn in
  iter_until_done pp_event
