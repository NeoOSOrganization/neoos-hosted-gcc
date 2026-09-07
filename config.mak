TARGET = x86_64-neoos-linux-musl
OUTPUT = /home/neo/opt/cross-x86_64-neoos
MUSL_VER = 1.2.5

# NeoOS's interrupt/syscall entry does not preserve the x86-64 red
# zone under a user context -- every other userland binary in this
# org (built via the freestanding x86_64-elf-gcc toolchain) has always
# passed -mno-red-zone explicitly for exactly this reason. Confirmed
# the hard way: a hosted_hello.c built by this toolchain WITHOUT this
# flag segfaulted (signal 11) with zero output, silently, the moment
# any leaf function (inside musl's own already-compiled code, not just
# user code) used the red zone. Both musl's own build AND target
# libraries (libgcc/libgcc_eh) need it -- a flag added only to future
# user-code compiles would leave musl's already-compiled .o files
# inside libc.a unprotected.
# -mcmodel=large: NeoOS's user.ld (see userland/user.ld) places user
# code at 0x200000000000 (PML4 slot 64, deliberately not slot 0) --
# far beyond what 32-bit-relative relocations (the small/medium code
# model's default) can reach. Every existing NeoOS userland binary
# already builds with this for exactly that reason (see neoos-musl's
# own build.sh). Confirmed the hard way: linking against user.ld
# without it fails outright with "relocation truncated to fit" against
# crt1.o/crtbeginT.o, which were compiled without it.
MUSL_CONFIG += CFLAGS="-mno-red-zone -mcmodel=large -fno-pic"
GCC_CONFIG += CFLAGS_FOR_TARGET="-mno-red-zone -mcmodel=large -fno-pic -g -O2"
