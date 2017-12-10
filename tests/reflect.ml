module T = Yaml_types.M
open Rresult

let reflect e ev pos =
  Yaml.Stream.emit e ev

let test () =
  let open R.Infix in
  Bos.OS.File.read (Fpath.v "anchor.yml") >>= fun buf ->
  Yaml.Stream.parser buf >>= fun t ->
  Yaml.Stream.emitter () >>= fun e ->
  let rec iter_until_done fn =
    Yaml.Stream.do_parse t >>= fun (e, pos) ->
    match e with 
    | Yaml.Stream.Event.Nothing -> R.ok ()
    | event -> fn event pos; iter_until_done fn in
  iter_until_done (reflect e) >>= fun () ->
  let r = Yaml.Stream.emitter_buf e in
  print_endline buf;
  print_endline (Bytes.to_string r); 
  Ok ()

let _ =
  match test () with
  | Ok _ -> ()
  | Error (`Msg m) ->
      prerr_endline m;
      exit 1
