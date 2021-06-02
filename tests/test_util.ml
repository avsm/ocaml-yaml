open Yaml.Util

let value = Alcotest.of_pp Yaml.pp

let err : [ `Msg of string ] Alcotest.testable =
  Alcotest.of_pp (fun ppf (`Msg m) -> Fmt.pf ppf "Error %s" m)

let value_res = Alcotest.result value err

let test_combinators () =
  let strings = [ "yaml"; "ocaml"; "yaml" ] in
  let expect = `A [ `String "yaml"; `String "ocaml"; `String "yaml" ] in
  let actual = list string strings in
  Alcotest.check value "same value" expect actual

let test_member () =
  let obj = `O [ ("alice", `String "ocaml"); ("bob", `String "yaml") ] in
  let expect = Ok (Some (`String "ocaml")) in
  let actual = find "alice" obj in
  Alcotest.check Alcotest.(result (option value) err) "same value" expect actual

let test_missing_member () =
  let obj = `O [ ("alice", `String "ocaml"); ("bob", `String "yaml") ] in
  let expect = Ok None in
  let actual = find "charlie" obj in
  Alcotest.check Alcotest.(result (option value) err) "same none" expect actual

let test_map () =
  let arr = `A [ `Float 1.; `Float 2.; `Float 3. ] in
  let expect = `A [ `String "1."; `String "2."; `String "3." ] in
  let actual =
    map_exn (fun f -> to_float_exn f |> string_of_float |> string) arr
  in
  Alcotest.check value "same array" expect actual

let test_filter () =
  let arr = `A [ `Float 1.; `Float 2.; `Float 3. ] in
  let expect = `A [ `Float 1.; `Float 2. ] in
  let actual = filter_exn (fun f -> to_float_exn f < 3.) arr in
  Alcotest.check value "same array" expect actual

let tests =
  [
    ("same yaml values", `Quick, test_combinators);
    ("find values", `Quick, test_member);
    ("missing value", `Quick, test_missing_member);
    ("same array with map", `Quick, test_map);
    ("same filtered array", `Quick, test_filter);
  ]
