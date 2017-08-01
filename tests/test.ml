let test_version () =
  let _s = Yaml.version () in
  let _v = Yaml.get_version () in
  ()

let () =
  test_version ()
