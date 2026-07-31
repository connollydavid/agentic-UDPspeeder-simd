#!/bin/bash
# Assemble a runnable target sysroot from an OpenWrt SDK, for running cross
# binaries under qemu-user.
#
# The pieces come from two places: the target root holds the C library, and the
# toolchain dir holds the loader and the C++ runtime. The target root is not
# always populated, so take what is missing from the toolchain.
set -u

SDK=${1:?usage: $0 <sdk-dir> <dest-dir>}
DEST=${2:?usage: $0 <sdk-dir> <dest-dir>}

rm -rf "$DEST"
mkdir -p "$DEST/lib" "$DEST/usr/lib"

root=$(ls -d "$SDK"/staging_dir/target-*/root-* 2>/dev/null | head -1)
tc=$(ls -d "$SDK"/staging_dir/toolchain-* 2>/dev/null | head -1)

if [ -n "$root" ]; then
	cp -a "$root"/lib/. "$DEST/lib/" 2>/dev/null
	cp -a "$root"/usr/lib/. "$DEST/usr/lib/" 2>/dev/null
fi

if [ -n "$tc" ]; then
	for f in ld-musl-*.so.1 libc.so libstdc++.so.6* libgcc_s.so.1* libatomic.so.1*; do
		cp -an "$tc"/lib/$f "$DEST/lib/" 2>/dev/null
	done
fi

cp -an "$DEST"/usr/lib/libstdc++.so.6* "$DEST/lib/" 2>/dev/null

# musl resolves a SONAME, so add the plain name where only a versioned file landed
( cd "$DEST/lib" && for so in libstdc++.so.6 libgcc_s.so.1; do
	if [ ! -e "$so" ]; then
		f=$(ls "$so".* 2>/dev/null | head -1)
		[ -n "$f" ] && ln -sf "$f" "$so"
	fi
done ) 2>/dev/null

if ! ls "$DEST"/lib/ld-musl-*.so.1 >/dev/null 2>&1; then
	echo "no musl loader found in $SDK" >&2
	exit 1
fi

echo "staged sysroot at $DEST"
