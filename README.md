# [MoonBit](https://www.moonbitlang.com/) WebAssembly component demo

Adapted from: https://component-model.bytecodealliance.org/tutorial.html.

For more information, check the [Makefile](Makefile).

## Build

```bash
> nix develop
> make
```

## Run

```bash
> wasmtime build/final.wasm 12 30 add
12 + 30 = 42
```

## Generate MoonBit WebAssembly bindings
```bash
> make adder/gen
> make calculator/gen
```

## TODO
- [ ] rewrite command in MoonBit
