exception Value_error of string

let keys = function
  | `O assoc -> Ok (List.map fst assoc)
  | _ -> Error (`Msg "Failed to get keys from non-object value")

let keys_exn = function
  | `O assoc -> List.map fst assoc
  | _ -> raise (Value_error "Failed to get keys from non-object value")

let values = function
  | `O assoc -> Ok (List.map snd assoc)
  | _ -> Error (`Msg "Failed to get values from non-object value")

let values_exn = function
  | `O assoc -> List.map snd assoc
  | _ -> raise (Value_error "Failed to get values from non-object value")

let combine a b =
  match (a, b) with
  | `O a, `O b -> Ok (`O (a @ b))
  | _ -> Error (`Msg "Expected two objects")

let combine_exn a b =
  match (a, b) with
  | `O a, `O b -> `O (a @ b)
  | _ -> raise (Value_error "Expected two objects")

let find s = function
  | `O assoc -> Ok (List.assoc_opt s assoc)
  | _ -> Error (`Msg "Expected an object")

let find_exn s = function
  | `O assoc -> List.assoc_opt s assoc
  | _ -> raise (Value_error "Expected an object")

let map f = function
  | `A lst -> Ok (`A (List.map f lst))
  | _ -> Error (`Msg "Expected a value array")

let map_exn f = function
  | `A lst -> `A (List.map f lst)
  | _ -> raise (Value_error "Expected a value array")

let filter p = function
  | `A lst -> Ok (`A (List.filter p lst))
  | _ -> Error (`Msg "Expected a value array")

let filter_exn p = function
  | `A lst -> `A (List.filter p lst)
  | _ -> raise (Value_error "Expected a value array")

let to_string = function
  | `String s -> Ok s
  | _ -> Error (`Msg "Expected a string value")

let to_string_exn = function
  | `String s -> s
  | _ -> raise (Value_error "Expected a string value")

let to_bool = function
  | `Bool b -> Ok b
  | _ -> Error (`Msg "Expected a bool value")

let to_bool_exn = function
  | `Bool b -> b
  | _ -> raise (Value_error "Expected a bool value")

let to_float = function
  | `Float f -> Ok f
  | _ -> Error (`Msg "Expected a float value")

let to_float_exn = function
  | `Float f -> f
  | _ -> raise (Value_error "Expected a float value")

let string s = `String s
let bool b = `Bool b
let float f = `Float f
let list f lst = `A (List.map f lst)
let obj assoc = `O assoc
