#!/bin/sh

set -e

ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/.env"

DEST=$ROOT/$HOST_TOOLS
mkdir -p "$DEST"

fetch_verified() {
	url=$1
	want=$2
	out=$3
	_tmp=$(mktemp)
	curl -fsSL -o "$_tmp" "$url"
	got=$(sha256sum "$_tmp" | cut -d' ' -f1)
	if [ "$got" != "$want" ]; then
		rm -f "$_tmp"
		echo "install-tools: sha256 mismatch for $url" >&2
		echo "  expected $want" >&2
		echo "  actual   $got" >&2
		exit 1
	fi
	mv "$_tmp" "$out"
	chmod 644 "$out"
}

install_node() {
	[ -x "$ROOT/$NODE" ] && { echo "node    $("$ROOT/$NODE" --version) (present)"; return; }
	tarball=node-$NODE_VERSION-linux-x64.tar.xz
	tmp=$(mktemp -d)
	curl -fsSL -o "$tmp/$tarball" "https://nodejs.org/dist/$NODE_VERSION/$tarball"
	curl -fsSL -o "$tmp/SHASUMS256.txt" "https://nodejs.org/dist/$NODE_VERSION/SHASUMS256.txt"
	want=$(grep " $tarball\$" "$tmp/SHASUMS256.txt" | cut -d' ' -f1)
	[ -n "$want" ] || { echo "install-tools: $tarball not in the published SHASUMS256.txt" >&2; exit 1; }
	got=$(sha256sum "$tmp/$tarball" | cut -d' ' -f1)
	[ "$got" = "$want" ] || { echo "install-tools: sha256 mismatch for $tarball" >&2; exit 1; }
	rm -rf "$DEST/node"
	tar -xJf "$tmp/$tarball" -C "$DEST"
	mv "$DEST/node-$NODE_VERSION-linux-x64" "$DEST/node"
	rm -rf "$tmp"
	echo "node    $("$ROOT/$NODE" --version) (installed)"
}

install_jdk() {
	[ -x "$ROOT/$JAVA" ] && { echo "jdk     $("$ROOT/$JAVA" -version 2>&1 | head -1) (present)"; return; }
	tmp=$(mktemp -d)
	fetch_verified "$JDK_URL" "$JDK_SHA256" "$tmp/jdk.tar.gz"
	rm -rf "$DEST/jdk"
	mkdir -p "$DEST/jdk"
	tar -xzf "$tmp/jdk.tar.gz" -C "$DEST/jdk" --strip-components=1
	rm -rf "$tmp"
	echo "jdk     $("$ROOT/$JAVA" -version 2>&1 | head -1) (installed)"
}

install_tla2tools() {
	[ -f "$ROOT/$TLA2TOOLS" ] && { echo "tlc     $TLA2TOOLS_VERSION (present)"; return; }
	mkdir -p "$(dirname "$ROOT/$TLA2TOOLS")"
	fetch_verified "$TLA2TOOLS_URL" "$TLA2TOOLS_SHA256" "$ROOT/$TLA2TOOLS"
	echo "tlc     $TLA2TOOLS_VERSION (installed)"
}

install_host_lifecycle() {
	[ -x "$ROOT/$HOST_LIFECYCLE" ] && { echo "lifecycle $("$ROOT/$HOST_LIFECYCLE" --version 2>&1 | head -1) (present)"; return; }
	mkdir -p "$(dirname "$ROOT/$HOST_LIFECYCLE")"
	fetch_verified "$HOST_LIFECYCLE_URL" "$HOST_LIFECYCLE_SHA256" "$ROOT/$HOST_LIFECYCLE"
	chmod 755 "$ROOT/$HOST_LIFECYCLE"
	echo "lifecycle $("$ROOT/$HOST_LIFECYCLE" --version 2>&1 | head -1) (installed)"
}

install_allium() {
	[ -x "$ROOT/$ALLIUM" ] && { echo "allium  $("$ROOT/$ALLIUM" --version 2>&1 | head -1) (present)"; return; }
	cargo install --locked --root "$DEST/allium" "allium-cli@$ALLIUM_VERSION"
	echo "allium  $("$ROOT/$ALLIUM" --version 2>&1 | head -1) (installed)"
}

case "${1:-all}" in
node) install_node ;;
jdk) install_jdk ;;
tla2tools) install_tla2tools ;;
host-lifecycle) install_host_lifecycle ;;
allium) install_allium ;;
all)
	install_node
	install_jdk
	install_tla2tools
	install_host_lifecycle
	install_allium
	;;
*)
	echo "usage: install-tools.sh [all|node|jdk|tla2tools|host-lifecycle|allium]" >&2
	exit 2
	;;
esac
