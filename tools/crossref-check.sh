#!/bin/sh

set -e

ROOT=$(cd "$(dirname "$0")/.." && pwd)

PATTERN='[A-Za-z0-9._-]+/[A-Za-z0-9._-]+#[0-9]+|github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/(issues|pull|commit)/'

usage() {
	echo "usage: crossref-check.sh <range> | --message <file> | --install" >&2
	exit 2
}

report() {
	label=$1
	hits=$2
	echo "crossref-check: $label" >&2
	echo "$hits" | sed 's/^/  /' >&2
}

remedy() {
	echo "" >&2
	echo "A commit message pushed to this public host mints a timeline event on the" >&2
	echo "upstream tracker, pulling the governance repo into that thread." >&2
	echo "Write the number without the linking form: openwrt/packages PR 30228." >&2
}

scan_range() {
	status=0
	for sha in $(git rev-list "$1"); do
		hits=$(git log -1 --format=%B "$sha" | grep -nEi "$PATTERN" || true)
		if [ -n "$hits" ]; then
			report "$sha $(git log -1 --format=%s "$sha")" "$hits"
			status=1
		fi
	done
	[ "$status" -eq 0 ] || remedy
	return $status
}

scan_message() {
	hits=$(grep -nEi "$PATTERN" "$1" | grep -v '^[0-9]*:#' || true)
	if [ -n "$hits" ]; then
		report "the commit message" "$hits"
		remedy
		return 1
	fi
	return 0
}

install_hook() {
	hooks=$(cd "$ROOT" && cd "$(git rev-parse --git-path hooks)" 2>/dev/null && pwd) || {
		hooks=$ROOT/$(git -C "$ROOT" rev-parse --git-path hooks)
		mkdir -p "$hooks"
	}
	cat > "$hooks/pre-push" <<EOF
#!/bin/sh

set -e

STATUS=0
while read -r _local_ref local_sha _remote_ref remote_sha; do
	[ "\$local_sha" = "0000000000000000000000000000000000000000" ] && continue
	if [ "\$remote_sha" != "0000000000000000000000000000000000000000" ]; then
		RANGE="\$remote_sha..\$local_sha"
	else
		RANGE="\$local_sha~1..\$local_sha"
	fi
	$ROOT/tools/crossref-check.sh "\$RANGE" || STATUS=1
done

exit \$STATUS
EOF
	chmod +x "$hooks/pre-push"
	echo "installed $hooks/pre-push"
}

case "${1:-}" in
"") usage ;;
--install) install_hook ;;
--message) [ -n "${2:-}" ] || usage; scan_message "$2" ;;
*) scan_range "$1" ;;
esac
