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

let prefix = "yaml_stub"

let prologue =
  "\n\
   #if defined(__MINGW32__) || defined(__MINGW64__)\n\
   #define __USE_MINGW_ANSI_STDIO 1\n\
   #include <stdio.h> /* see: https://sourceforge.net/p/mingw-w64/bugs/627/ */\n\
   #endif\n\
   #include <yaml.h>\n"

let () =
  print_endline prologue;
  Cstubs.Types.write_c Format.std_formatter (module Yaml_bindings_types.M)
