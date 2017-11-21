let test_version () =
  let _s = Yaml.Stream.version () in
  let _v = Yaml.Stream.get_version () in
  ()

let () =
  test_version ()
