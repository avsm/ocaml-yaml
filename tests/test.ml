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

let files = [ "anchor.yml"; "cohttp.yml"; "linuxkit.yml"; "seq.yml"; "too_large.yml" ]
let dir f = Fpath.(v "yaml" / f)

let all_files = List.map dir ("bomb.yml"::files)
let all_simple_files = List.map dir files

type error = [`Msg of string]
let pp_error ppf (`Msg x) = Fmt.string ppf x
let error = Alcotest.testable pp_error (=)
let t = Alcotest.(result unit error)
let value = Alcotest.testable Yaml.pp Yaml.equal
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

let quoted_scalars =
  (* Given an input string, we want to test two things:
    - if the input is parsed as an expected Yaml.value and;
    - if encoding the parsed Yaml.yaml results in the original string. *)
  let open Rresult.R.Infix in
  let test name str expected =
    let actual_yaml = Yaml.yaml_of_string str in
    let actual_value = actual_yaml >>= Yaml.to_json in
    let str' = actual_yaml >>= Yaml.yaml_to_string in
    (name, `Quick, Alcotest.(fun () ->
      check (result value error) (name ^ " value") (Ok expected) actual_value;
      check (result string error) (name ^ " encoding") (Ok (str ^ "\n")) str'));
  in [
    test "quoted bool" {|'true'|} (`String "true");
    test "quoted null" {|'null'|} (`String "null");
    test "quoted float" {|'2.718'|} (`String "2.718");
    test "quoted string" {|"bar"|} (`String "bar");
    test "quoted int" {|"42"|} (`String "42");
    test "plain int" {|42|} (`Float 42.0);
    test "plain bool" {|true|} (`Bool true);
    test "plain string" {|foo|} (`String "foo");
    test "plain string with quote" {|foo 'bar'|} (`String "foo 'bar'");
    test "plain string with int and quote" {|42 "foo"|} (`String {|42 "foo"|});
    test "double quoted string" {|"'foo bar'"|} (`String "'foo bar'");
    test "partially double quoted string" {|'foo "bar"'|} (`String {|foo "bar"|});
  ]

let yaml_equal =
  let test name expected v1 v2 =
    (name, `Quick, Alcotest.(fun () ->
      check bool name expected (Yaml.equal v1 v2)));
  in [
    test "two null equal" true `Null `Null;
    test "two floats equal" true (`Float 2.718) (`Float 2.718);
    test "two floats not equal" false (`Float 2.718) (`Float 3.141);
    test "two bools equal" true (`Bool true) (`Bool true);
    test "two strings equal" true (`String "foo") (`String "foo");
    test "two strings not equal" false (`String "foo") (`String "bar");
    test "two arrays equal" true (`A [`String "foo"; `Null; `Bool true]) (`A [`String "foo"; `Null; `Bool true]);
    test "two arrays not equal" false (`A [`Null]) (`A [`String "foo"; `Null; `Bool true]);
    test "two objects equal" true (`O ["a", `A [`String "foo"; `Null]]) (`O ["a", `A [`String "foo"; `Null]]);
    test "different types not equal" false (`Float 2.718) (`O ["k1", `String "foo"; "k2", `Null; "k3", `Bool true]);
  ]

let tests = [
    "parse_event_test_set", parse_event_test_set all_files;
    "parse_of_string", parse_of_string all_simple_files;
    "reflect", reflect all_files;
    "emit", emit;
    "version", version;
    "quoted_scalars", quoted_scalars;
    "yaml_equal", yaml_equal;
  ]

(* Run it *)
let () =
  Junit_alcotest.run_and_report "Yaml" tests |>
  fun (r,e) ->
  Junit.(to_file (make [r]) "alcotest-junit.xml");
  e ()
