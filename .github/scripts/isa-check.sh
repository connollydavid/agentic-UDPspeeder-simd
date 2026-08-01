#!/bin/bash
# Assert that a binary really is built for the instruction set its target
# claims, so a permissive emulator model cannot hide a mismatch.
#
# This exists for arm_fa526. That target is plain ARMv4, which has no bx and so
# cannot enter Thumb code, while qemu-user always maps a Thumb vdso: the call to
# __vdso_gettimeofday runs Thumb bytes in ARM state and lands in the weeds. Real
# hardware never meets this, because the Linux ARM vdso needs ARMv7 and such a
# kernel supplies none. Running that architecture under a model that can
# interwork keeps the runtime coverage; this check is the other half, holding
# the binary to ARMv4 so the richer model proves nothing false.
set -u

usage() {
	echo "usage: $0 --binary <path> --expect <arch> --objdump <program>" >&2
	exit 2
}

BINARY=""; EXPECT=""; OBJDUMP=""
while [ $# -gt 0 ]; do
	case "$1" in
		--binary) BINARY=$2; shift 2 ;;
		--expect) EXPECT=$2; shift 2 ;;
		--objdump) OBJDUMP=$2; shift 2 ;;
		*) usage ;;
	esac
done
[ -n "$BINARY" ] && [ -n "$EXPECT" ] && [ -n "$OBJDUMP" ] || usage
[ -e "$BINARY" ] || { echo "no such binary: $BINARY" >&2; exit 1; }

# The ARM expectations below hold a binary to no more than its target's
# instruction set, because a richer emulator model would run past it unnoticed.
# This one runs the other way and holds a binary to containing something. The
# SPE XOR on the e500v2 is reached through a build flag rather than a macro, so
# losing the flag costs the fastest path on that target and changes nothing a
# packet test can see. Requiring the opcodes turns that silence into a failure.
if [ "$EXPECT" = "spe" ]; then
	found=$("$OBJDUMP" -d "$BINARY" 2>/dev/null |
		grep -cE '\bev(ldd|stdd|xor)\b' || true)
	if [ "$found" -eq 0 ]; then
		echo "ISA FAIL $(basename "$BINARY"): no SPE opcodes, the e500 XOR was not built" >&2
		exit 1
	fi
	echo "ISA OK $(basename "$BINARY"): $found SPE opcodes present"
	exit 0
fi

got=$(readelf -A "$BINARY" 2>/dev/null | sed -n 's/.*Tag_CPU_arch: //p' | head -1)
if [ "$got" != "$EXPECT" ]; then
	echo "ISA FAIL $(basename "$BINARY"): Tag_CPU_arch is '$got', expected '$EXPECT'" >&2
	exit 1
fi

# Instructions that postdate the expected level. Anything here means the build
# reaches past the target CPU, which the emulator would happily run anyway.
case "$EXPECT" in
	v4) beyond='bx|blx|clz|ldrd|strd|pld|ldrex|strex|dmb|dsb|isb|movw|movt|sdiv|udiv|rbit|bfi|bfc' ;;
	v5|v5T|v5TE|v5TEJ) beyond='ldrex|strex|dmb|dsb|isb|movw|movt|sdiv|udiv|rbit|bfi|bfc' ;;
	*) echo "no instruction screen defined for '$EXPECT'; attribute check only"
	   echo "ISA OK $(basename "$BINARY"): Tag_CPU_arch $got"
	   exit 0 ;;
esac

found=$("$OBJDUMP" -d "$BINARY" 2>/dev/null |
	awk -v re="^($beyond)$" '{for (i = 1; i <= NF; i++) if ($i ~ re) print $i}' |
	sort | uniq -c | sort -rn)

if [ -n "$found" ]; then
	echo "ISA FAIL $(basename "$BINARY"): instructions past $EXPECT present:" >&2
	echo "$found" | sed 's/^/  /' >&2
	exit 1
fi

echo "ISA OK $(basename "$BINARY"): Tag_CPU_arch $got, no instructions past $EXPECT"
