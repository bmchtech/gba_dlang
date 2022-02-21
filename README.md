
# gba_dlang

a toolkit (libraries + runtime) for using the D programming language to develop for the [Game Boy Advance](https://en.wikipedia.org/wiki/Game_Boy_Advance) handheld game console.

## about
yes, you read that right! this is a dlang library and runtime for the gameboy advance.

### what's included
- minimal druntime
- minimal core.stdc, std, rt, object.d
- libtonc bindings
- maxmod bindings
- gbfs bindings
- utilities for mmio and volatile bare metal io

## requirements

**tested on LDC2 version: `1.28.1 (DMD v2.098.1, LLVM 13.0.1)`**

i focused on making this as easy as possible to set up!
all you need is a recent build of the LLVM D compiler (LDC), and a standard devkitarm installation.

for maximum compatibility, i also provide a batteries included docker image that includes devkitarm and D and is fully able to build GBA roms.
the docker container can be found here: https://github.com/redthing1/dkarm_gba_docker

## demo
see the [demo project](demo/) for a fully functional example of building a gba rom with dlang.

```sh
cd demo
make clean
make build
mgba-qt GBADlang.gba
```

## troubleshooting

### errors about `__aeabi_read_tp`

this is about trying to read thread-local storage (TLS) for global variables. on a bare metal system like the GBA it's easier to just not worry about TLS and just go with thread-global storage.

if you get these errors, make sure you prefix your global variables with `__gshared`. this enables default C-style behavior of thread global storage.

### errors about `TLS reference ... mismatches non-TLS definition ... section .bss`

this means you're using a non-TLS variable with a TLS reference. this can often happen if you're individually compiling objects and then linking after you change the thread storage type of your variable. the solution is to just clean all intermediate object files and rebuild.

## acknowledgements

this would not have been possible without:
- [3ds-hello-dlang](https://github.com/TheGag96/3ds-hello-dlang/)