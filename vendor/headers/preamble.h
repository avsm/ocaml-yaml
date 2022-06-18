#if defined(__MINGW32__) || defined(__MINGW64__)
#define __USE_MINGW_ANSI_STDIO 1
#include <stdio.h> /* see: https://sourceforge.net/p/mingw-w64/bugs/627/ */
#endif
#include <yaml.h>
