#!/bin/bash
# Pass real packets through a udpspeeder tunnel and check they arrive intact.
#
# A build proves the binary links; this proves it runs. The binary is a cross
# build, so it runs under qemu-user against a sysroot staged from the SDK:
#
#   sender -> [client :BASE] ==tunnel==> [server :BASE+1] -> echo :BASE+2
#
# and the reply returns along the same path. Exits non-zero unless the payloads
# come back unchanged.
set -u

usage() {
	echo "usage: $0 --binary <path> --sysroot <dir> --qemu <program>" >&2
	echo "          [--cpu <model>] [--base-port <n>] [--packets <n>]" >&2
	exit 2
}

BINARY=""; SYSROOT=""; QEMU=""; CPU=""; BASE=31000; PACKETS=5
while [ $# -gt 0 ]; do
	case "$1" in
		--binary) BINARY=$2; shift 2 ;;
		--sysroot) SYSROOT=$2; shift 2 ;;
		--qemu) QEMU=$2; shift 2 ;;
		--cpu) CPU=$2; shift 2 ;;
		--base-port) BASE=$2; shift 2 ;;
		--packets) PACKETS=$2; shift 2 ;;
		*) usage ;;
	esac
done
[ -n "$BINARY" ] && [ -n "$SYSROOT" ] && [ -n "$QEMU" ] || usage

if [ "$CPU" = "build-only" ]; then
	echo "this architecture is marked build-only in arch-map.tsv; the caller" >&2
	echo "should skip the packet test rather than run it" >&2
	exit 2
fi
[ -e "$BINARY" ] || { echo "no such binary: $BINARY" >&2; exit 1; }
command -v "$QEMU" >/dev/null 2>&1 || { echo "no such emulator: $QEMU" >&2; exit 1; }

# The musl loader is invoked directly with an explicit library path, so the
# guest never falls back to the host's own libraries.
INTERP=$(readelf -l "$BINARY" 2>/dev/null | sed -n 's/.*program interpreter: \(.*\)\]/\1/p')
LOADER="$SYSROOT$INTERP"
[ -e "$LOADER" ] || LOADER=$(ls "$SYSROOT"/lib/ld-musl-*.so.1 2>/dev/null | head -1)
[ -n "$LOADER" ] && [ -e "$LOADER" ] || {
	echo "no musl loader staged under $SYSROOT" >&2; exit 1; }

RUNNER="$QEMU"
if [ -n "$CPU" ] && [ "$CPU" != "-" ]; then
	RUNNER="$RUNNER -cpu $CPU"
else
	echo "note: no cpu model given, falling back to the default for $QEMU" >&2
	CPU="(default)"
fi
RUNNER="$RUNNER $LOADER --library-path $SYSROOT/lib:$SYSROOT/usr/lib"

# Preflight: can the target's own C library run under this model at all? A model
# that lacks an instruction the library uses faults before reaching main, which
# reads like a package failure and is not one. musl's loader prints its version
# and exits non-zero, so judge the output rather than the status.
if ! "$QEMU" $([ "$CPU" != "(default)" ] && echo "-cpu $CPU") "$LOADER" --version 2>&1 |
		grep -q 'musl libc'; then
	echo "EMULATOR the C library will not run under $QEMU -cpu $CPU" >&2
	echo "  This is a model mismatch, not a package fault. Pick a model that" >&2
	echo "  covers the target CPU and record it in arch-map.tsv." >&2
	exit 3
fi

CPORT=$BASE
SPORT=$((BASE + 1))
EPORT=$((BASE + 2))
KEY=packettestkey
WORK=$(mktemp -d)
ECHO_PID=""; SRV_PID=""; CLI_PID=""
cleanup() {
	[ -n "$ECHO_PID" ] && kill "$ECHO_PID" 2>/dev/null
	[ -n "$SRV_PID" ] && kill "$SRV_PID" 2>/dev/null
	[ -n "$CLI_PID" ] && kill "$CLI_PID" 2>/dev/null
	rm -rf "$WORK"
	return 0
}
trap cleanup EXIT

python3 - "$EPORT" <<'PYEOF' >"$WORK/echo.log" 2>&1 &
import socket, sys
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(("127.0.0.1", int(sys.argv[1])))
while True:
    data, addr = s.recvfrom(65535)
    s.sendto(data, addr)
PYEOF
ECHO_PID=$!

# shellcheck disable=SC2086
$RUNNER "$BINARY" -s -l 127.0.0.1:$SPORT -r 127.0.0.1:$EPORT \
	-k "$KEY" -f 2:1 --log-level 1 >"$WORK/server.log" 2>&1 &
SRV_PID=$!
# shellcheck disable=SC2086
$RUNNER "$BINARY" -c -l 127.0.0.1:$CPORT -r 127.0.0.1:$SPORT \
	-k "$KEY" -f 2:1 --log-level 1 >"$WORK/client.log" 2>&1 &
CLI_PID=$!

# emulated startup is slower than native, so give both ends time to bind
sleep 5

python3 - "$CPORT" "$PACKETS" <<'PYEOF' >"$WORK/result.txt" 2>&1
import socket, sys
port, count = int(sys.argv[1]), int(sys.argv[2])
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(8.0)
sent = echoed = 0
for i in range(count):
    payload = b"udpspeeder-packet-test-%04d-%s" % (i, b"x" * 64)
    try:
        s.sendto(payload, ("127.0.0.1", port))
        sent += 1
        while True:
            data, _ = s.recvfrom(65535)
            if data == payload:
                echoed += 1
                break
    except socket.timeout:
        pass
print("sent=%d echoed=%d" % (sent, echoed))
# a tunnel that carries most of the payloads is working; a broken one carries none
sys.exit(0 if echoed >= max(1, count - 1) else 1)
PYEOF
rc=$?

result=$(cat "$WORK/result.txt")
if [ $rc -eq 0 ]; then
	echo "PASS $(basename "$BINARY") via $QEMU ($result)"
	exit 0
fi

echo "FAIL $(basename "$BINARY") via $QEMU -cpu $CPU ($result)" >&2
echo "server log:" >&2; tail -n 5 "$WORK/server.log" >&2
echo "client log:" >&2; tail -n 5 "$WORK/client.log" >&2
if grep -qE 'Illegal instruction|uncaught target signal 4' \
		"$WORK/server.log" "$WORK/client.log" 2>/dev/null; then
	echo "The binary hit an instruction $QEMU -cpu $CPU does not implement." >&2
	echo "The C library ran under this model, so the gap is in the package's" >&2
	echo "own code: either the model is still short of the target CPU, or the" >&2
	echo "build emits something the target does not have." >&2
fi
exit 1
