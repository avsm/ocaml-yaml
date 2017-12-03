open Rresult
open R.Infix

module S = Yaml.Stream

let test () =
  S.emitter () >>= fun t ->
  let buf = Bytes.create 200 in
  S.set_output_string t buf;
  S.stream_start t `Utf8 >>= fun () ->
  S.document_start t >>= fun () ->
  S.sequence_start t >>= fun () ->
  S.scalar ~tag:"sup" t "foo" >>= fun () ->
  S.mapping_start ~tag:"xx" t >>= fun () ->
  S.scalar ~tag:"sup" t "foo" >>= fun () ->
  S.scalar ~tag:"sup" t "bar" >>= fun () ->
  S.mapping_end t >>= fun () ->
  S.mapping_start t >>= fun () ->
  S.scalar ~tag:"bar" t "foo" >>= fun () ->
  S.sequence_start t >>= fun () ->
  S.scalar t ~tag:"bar" "foo" >>= fun () ->
  S.scalar t ~tag:"bar2" "foo" >>= fun () ->
  S.scalar t ~tag:"bar3" "foo" >>= fun () ->
  S.sequence_end t >>= fun () ->
  S.mapping_end t >>= fun () ->
  S.sequence_end t >>= fun () ->
  S.document_end t >>= fun () ->
  S.stream_end t >>= fun () ->
  Printf.printf "written: %d\n%!" (S.emitter_written t);
  let r = Bytes.sub buf 0 (S.emitter_written t) in
  print_endline r;
  Ok ()
  
let _ =
  match test () with
  | Ok () -> print_endline "ok"
  | Error (`Msg m) -> print_endline m; exit 1
