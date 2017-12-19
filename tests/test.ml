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

let files = [ "anchor.yml"; "cohttp.yml"; "linuxkit.yml"; "seq.yml" ]
let dir f = Fpath.(v "yaml" / f)

let all_files = List.map dir ("bomb.yml"::files)
let all_simple_files = List.map dir files

type error = [`Msg of string]
let pp_error ppf (`Msg x) = Fmt.string ppf x
let error = Alcotest.testable pp_error (=)
let t = Alcotest.(result unit error)
let check_file f fn =
  let name = Fpath.to_string f in
  let test () = Alcotest.check t name (Ok ()) (fn f) in
  name, `Quick, test

let parse_event_test_set =
  List.map (fun f -> check_file f Test_event_parse.v)

let parse_of_string =
  List.map (fun f -> check_file f Test_parse.v)

let reflect =
  List.map (fun f -> check_file f Test_reflect.v)

let emit =
  [ "emit", `Quick, (fun () -> Alcotest.check t "emit" (Ok ()) (Test_emit.v ())) ]

let version =
  [ "version", `Quick, (fun () -> Alcotest.check t "version" (Ok ()) (Test_version.v ())) ]

(* Run it *)
let () =
  Alcotest.run "Event-based parsed" [
    "parse_event_test_set", parse_event_test_set all_files;
    "parse_of_string", parse_of_string all_simple_files;
    "reflect", reflect all_files;
    "emit", emit;
    "version", version
  ]

