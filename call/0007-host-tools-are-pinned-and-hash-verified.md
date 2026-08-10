# The tools this host runs are pinned and hash-verified

- Status: accepted
- Scope: agentic-UDPspeeder-simd
- Date: 2026-08-10

## Context and Problem Statement

The methodology pins the software a host *builds*. A component records a source
pin, a build recipe, an artifact hash, and may record a `deps-bundle` so the
build reproduces offline from inputs fixed in advance rather than from whatever a
network fetch returns that day.

It says nothing about the tools the host *itself* runs. Those were reached
through whatever this machine happened to carry. On 2026-08-10 that meant node
and allium from `~/.local`, java from `/usr/sbin`, and `tla2tools.jar` from a
home share. Nothing recorded which versions those were, and nothing would have
noticed had they drifted.

The failure this invites is the one the OpenWrt work already taught. A package
build that fetches its dependencies at build time is not reproducible, however
carefully its source is pinned, because the fetch is the unpinned input. The same
holds one level up: a gate is only as trustworthy as the binary that runs it, and
an unpinned binary makes the gate's verdict a property of the machine rather than
of the change under it.

Two concrete symptoms had already appeared. A generated pre-push hook carried
`$HOME/.local/bin/node`, so it worked here and nowhere else. And a stale
`target/release/host-lint` sat six minor versions behind the binary on `PATH`,
which turned a green suite red and cost an hour before the cause was found.

## Decision

Every tool this host runs installs to a project-local path, at a version and a
sha256 recorded in the repository.

`.env` names each tool's version and its in-tree path.
`tools/install-tools.sh` fetches each one into `.host-tools/` and verifies its
sha256 **before** unpacking it, refusing on a mismatch. `.host-tools/` is
gitignored: the recipe is committed, the binaries are not. Scripts read `.env`
rather than probing `PATH`, so a hook or a lane names the tool it means.

Where a publisher ships its own checksum file, the script verifies against that
rather than a hash we copied: node against the published `SHASUMS256.txt`, the
JDK against the Adoptium API's checksum. Where none exists, the recorded hash is
the one this project pinned, and a change to it is a visible diff.

## Consequences

A fresh clone gets the same tool versions as this one, and a drifted download
fails loudly at the point of installation rather than quietly at the point of
use.

The cost is that a tool upgrade is now a commit: the version and the hash both
move in `.env`, and that is the intent.

Two limits are worth stating plainly. The install verifies provenance, not
behaviour, so a tool that is authentic and wrong still passes. And `.host-tools/`
holds around 550 MB, mostly the JDK, which is a real cost on a machine that
already carries one.

This decision is scoped to this host. The general form, a pinned and
hash-verified tool set recorded in `.host-software` and checked by
`software --verify-setup`, is a change to the shared methodology and belongs
upstream in the template, proposed there rather than settled here.

## Notes

`allium` is pinned to 3.5.0 rather than the template's 3.4.2. Neither version
installs from crates.io without `--locked`: `allium-cli` resolves a newer
`allium-parser` whose `analyze_with_cross_module` takes more arguments than the
call site supplies. 3.5.0 is the version `tools/allium` carries.
