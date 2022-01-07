
# gba_dlang

dlang libraries and runtime for the gameboy advance

## about
yes, you read that right! this is a dlang library and runtime for the gameboy advance.

### acknowledgements

this would not have been possible without:
- [3ds-hello-dlang](https://github.com/TheGag96/3ds-hello-dlang/)

### what's included
- minimal druntime
- minimal core.stdc, std, rt, object.d
- libtonc bindings
- utilities for mmio and volatile bare metal io

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