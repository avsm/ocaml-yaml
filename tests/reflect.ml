module T = Yaml_types.M
open Rresult

let reflect e ev pos =
  Yaml.Stream.emit e ev

let test () =
  let open R.Infix in
  Bos.OS.File.read (Fpath.v "cohttp.yml") >>= fun buf ->
  Yaml.Stream.parser () >>= fun t ->
  Yaml.Stream.emitter () >>= fun e ->
  let obuf = Bytes.create 4096 in
  Yaml.Stream.set_output_string e obuf;
  let rec iter_until_done fn =
    Yaml.Stream.do_parse t >>= fun (e, pos) ->
    match e with 
    | Yaml.Stream.Event.Nothing -> R.ok ()
    | event -> fn event pos; iter_until_done fn in
  Yaml.Stream.set_input_string t buf;
  iter_until_done (reflect e) >>= fun () ->
  let r = Bytes.sub obuf 0 (Yaml.Stream.emitter_written e) in
  print_endline buf;
  print_endline r; 
  Ok ()

let _ =
  match test () with
  | Ok _ -> ()
  | Error (`Msg m) ->
      prerr_endline m;
      exit 1
