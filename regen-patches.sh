#!/bin/bash
set -e
# Regenerates patches/musl-1.2.5/*.diff from a FRESH musl v1.2.5 checkout
# and the CURRENT third_party/shim/* in the NeoOS kernel repo -- run this
# whenever that shim changes. (This repo's initial patches were generated
# from the shim's pre-existing .orig pairs instead, which is equivalent
# but doesn't need a fresh checkout when those pairs already exist.)
SHIM_DIR="${SHIM_DIR:-../NeoOS/third_party/shim}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

git clone --depth 1 --branch v1.2.5 https://git.musl-libc.org/git/musl "$WORK/musl"
cp "$WORK/musl/arch/x86_64/syscall_arch.h" "$WORK/musl/arch/x86_64/syscall_arch.h.pristine"
cp "$WORK/musl/src/thread/x86_64/syscall_cp.s" "$WORK/musl/src/thread/x86_64/syscall_cp.s.pristine"
cp "$WORK/musl/src/thread/x86_64/__set_thread_area.s" "$WORK/musl/src/thread/x86_64/__set_thread_area.s.pristine"
cp "$WORK/musl/src/thread/x86_64/__unmapself.s" "$WORK/musl/src/thread/x86_64/__unmapself.s.pristine"
cp "$WORK/musl/src/thread/x86_64/clone.s" "$WORK/musl/src/thread/x86_64/clone.s.pristine"
cp "$WORK/musl/src/signal/x86_64/restore.s" "$WORK/musl/src/signal/x86_64/restore.s.pristine"
cp "$WORK/musl/src/process/x86_64/vfork.s" "$WORK/musl/src/process/x86_64/vfork.s.pristine"

cp "$SHIM_DIR/syscall_arch.h" "$WORK/musl/arch/x86_64/syscall_arch.h"
cp "$SHIM_DIR/syscall_cp.s" "$WORK/musl/src/thread/x86_64/syscall_cp.s"
cp "$SHIM_DIR/__set_thread_area.s" "$WORK/musl/src/thread/x86_64/__set_thread_area.s"
cp "$SHIM_DIR/__unmapself.s" "$WORK/musl/src/thread/x86_64/__unmapself.s"
cp "$SHIM_DIR/clone.s" "$WORK/musl/src/thread/x86_64/clone.s"
cp "$SHIM_DIR/restore.s" "$WORK/musl/src/signal/x86_64/restore.s"
cp "$SHIM_DIR/vfork.s" "$WORK/musl/src/process/x86_64/vfork.s"

mkdir -p patches/musl-1.2.5
cd "$WORK/musl"
# -p1 strips exactly one leading path component, so every header needs
# a real a/ or b/ prefix -- not just the bare relative path (a past
# version of this script omitted that and produced patches `patch -p1`
# could not locate the target file for at all).
diff -u arch/x86_64/syscall_arch.h.pristine arch/x86_64/syscall_arch.h \
    | sed 's|arch/x86_64/syscall_arch.h.pristine|a/arch/x86_64/syscall_arch.h|; s|^\+\+\+ arch/x86_64/syscall_arch.h|+++ b/arch/x86_64/syscall_arch.h|' \
    > "$OLDPWD/patches/musl-1.2.5/001-syscall_arch.diff"
diff -u src/thread/x86_64/syscall_cp.s.pristine src/thread/x86_64/syscall_cp.s \
    | sed 's|src/thread/x86_64/syscall_cp.s.pristine|a/src/thread/x86_64/syscall_cp.s|; s|^\+\+\+ src/thread/x86_64/syscall_cp.s|+++ b/src/thread/x86_64/syscall_cp.s|' \
    > "$OLDPWD/patches/musl-1.2.5/002-syscall_cp.diff"
diff -u src/thread/x86_64/__set_thread_area.s.pristine src/thread/x86_64/__set_thread_area.s \
    | sed 's|src/thread/x86_64/__set_thread_area.s.pristine|a/src/thread/x86_64/__set_thread_area.s|; s|^\+\+\+ src/thread/x86_64/__set_thread_area.s|+++ b/src/thread/x86_64/__set_thread_area.s|' \
    > "$OLDPWD/patches/musl-1.2.5/003-set_thread_area.diff"
diff -u src/thread/x86_64/__unmapself.s.pristine src/thread/x86_64/__unmapself.s \
    | sed 's|src/thread/x86_64/__unmapself.s.pristine|a/src/thread/x86_64/__unmapself.s|; s|^\+\+\+ src/thread/x86_64/__unmapself.s|+++ b/src/thread/x86_64/__unmapself.s|' \
    > "$OLDPWD/patches/musl-1.2.5/004-unmapself.diff"
diff -u src/thread/x86_64/clone.s.pristine src/thread/x86_64/clone.s \
    | sed 's|src/thread/x86_64/clone.s.pristine|a/src/thread/x86_64/clone.s|; s|^\+\+\+ src/thread/x86_64/clone.s|+++ b/src/thread/x86_64/clone.s|' \
    > "$OLDPWD/patches/musl-1.2.5/005-clone.diff"
diff -u src/signal/x86_64/restore.s.pristine src/signal/x86_64/restore.s \
    | sed 's|src/signal/x86_64/restore.s.pristine|a/src/signal/x86_64/restore.s|; s|^\+\+\+ src/signal/x86_64/restore.s|+++ b/src/signal/x86_64/restore.s|' \
    > "$OLDPWD/patches/musl-1.2.5/006-restore.diff"
diff -u src/process/x86_64/vfork.s.pristine src/process/x86_64/vfork.s \
    | sed 's|src/process/x86_64/vfork.s.pristine|a/src/process/x86_64/vfork.s|; s|^\+\+\+ src/process/x86_64/vfork.s|+++ b/src/process/x86_64/vfork.s|' \
    > "$OLDPWD/patches/musl-1.2.5/007-vfork.diff"
diff -u /dev/null "$SHIM_DIR/neoos_syscall.c" \
    | sed "s|^\+\+\+ .*neoos_syscall.c|+++ b/src/internal/neoos_syscall.c|" \
    > "$OLDPWD/patches/musl-1.2.5/008-neoos_syscall.diff"
echo "Regenerated patches/musl-1.2.5/*.diff"
