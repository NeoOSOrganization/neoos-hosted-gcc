# neoos-hosted-gcc

A hosted `x86_64-neoos-musl` GCC/G++ cross-toolchain for NeoOS: real
libc (NeoOS's own patched musl), real CRT startup, real C++ exception
unwinding (`crtbeginT.o`, `libgcc_eh.a`) -- unlike the freestanding
`x86_64-elf-gcc` toolchain every other NeoOS port builds with, which
is deliberately bare-metal (no libc, no hosted C++ runtime) and cannot
provide those.

Built via [`musl-cross-make`](https://github.com/richfelker/musl-cross-make)'s
standard three-stage bootstrap (binutils -> freestanding stage-1 GCC ->
target libc -> full stage-2 GCC/G++), with one substitution: the libc
stage builds real musl v1.2.5 sources patched via the diffs in
`patches/musl-1.2.5/`, which mirror `NeoOS/third_party/shim/*` exactly
-- so the toolchain's bundled libc is genuinely NeoOS's own patched
musl, not stock.

See `docs/superpowers/specs/2026-09-07-hosted-neoos-gcc-design.md` and
`docs/superpowers/plans/2026-09-07-hosted-neoos-gcc.md` in the
`NeoOS` (kernel) repo for the full design and implementation plan.

## Building

```bash
./build.sh
```

Installs to `/home/neo/opt/cross-x86_64-neoos` (see `config.mak`).
Takes on the order of 30-90+ minutes -- a real binutils+GCC bootstrap,
not a quick build.

## Regenerating the shim patches

If `NeoOS/third_party/shim/*` changes, regenerate
`patches/musl-1.2.5/*.diff` from it:

```bash
./regen-patches.sh
```

The shim's source of truth stays `NeoOS/third_party/shim/` -- this
repo's patches are a generated reflection of it, not a second copy to
maintain by hand.
