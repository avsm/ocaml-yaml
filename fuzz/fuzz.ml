(* Copyright (c) 2017 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. *)

open Crowbar
open Rresult
open R.Infix

(* Consume all the events in a stream using the 
   low-level API and return a bool to indicate success *)
let consume_all_events buf =
  let r = 
    Yaml.Stream.parser buf >>= fun t ->
    let rec iter () =
      Yaml.Stream.do_parse t >>= fun (e, pos) ->
      match e with
      | Yaml.Stream.Event.Stream_end -> Ok ()
      | Yaml.Stream.Event.Nothing -> Error (`Msg "nothing")
      | _ -> iter () in
    iter () in
  match r with
  | Ok () -> true
  | Error (`Msg m) -> false
  
let yaml = 
  map [bytes] (fun s ->
    match Yaml.of_string s with
    | Ok y -> s,y
    | Error _ -> bad_test ())

let yaml_pp ppf (s,y) =
  Printf.sprintf "%S\n%s\n" s (Yaml.to_string_exn y) |>
  Format.pp_print_string ppf

let yaml = with_printer yaml_pp yaml

let to_from orig =
  let r = Yaml.to_string orig >>= Yaml.of_string in
  match r with
  | Ok s -> s 
  | Error (`Msg m) -> raise (Failure m)
 
let events_test buf =
  match Yaml.of_string buf with
  | Ok y -> consume_all_events buf
  | Error (`Msg msg) -> consume_all_events buf = false

let () =
  (add_test ~name:"yaml" [yaml] @@ fun (s,y) ->
    check_eq ~pp:Yaml.pp (to_from y) y);
  (add_test ~name:"events" [bytes] @@ fun buf ->
    check (events_test buf));
  ()
