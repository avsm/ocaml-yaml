This is a copy of https://github.com/yaml/libyaml.git
revision 660242d6a418f0348c61057ed3052450527b3abf.

yaml.h has been modified to remove anonymous structs, since ocaml-ctypes stub
generation needs to probe their sizes at compile-time.
