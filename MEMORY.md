# The agent's own append-only working memory. Excluded from the naming and prose
# audits via .host-lintignore; never rewrite an old entry (correct in place with a
# dated pointer). A fresh session reads plan/, call/, and this file to continue.

## 2026-07-02 — host adopted

- Adopted `host-template` @ `565410a` for UDPspeeder-simd (case a, Shallow). Stamp
  written by `host-lifecycle adopt`; rooms `cast/ plan/ call/` scaffolded.
- Push auth: the stored git credential is the `slartibardfast` token, which had no
  push rights to `connollydavid/agentic-UDPspeeder-simd` (HTTP 403 on first dry-run
  push). The operator authorized the repo, after which `git push --dry-run` returned
  "Everything up-to-date". If a later push 403s again, surface it to the operator
  rather than retrying blindly.
- Tooling built from source with the system toolchain (rustc 1.96.1, Arch Linux).
  The methodology pins Rust 1.95.0 as the reproducible-build anchor; the local
  builds use 1.96.1, which is newer and builds clean. Record this wherever a
  canonical artifact hash is claimed.
- UDPspeeder-simd embeds as a bare store plus worktree at
  `software/udpspeeder-simd/branch_libev/` (its default branch is `branch_libev`,
  not `main`). Recorded in `.host-software` with no `deploy`/`artifact`, so it is a
  source pin with no reproducible-build claim yet (migrated software).
- host-lint is also a `.host-software` component (the gating tool): `--install-hooks`
  reads a component's `hooks` script and built `artifact` from its materialized
  worktree, so host-lint must be materialized and built for the commit gate to land.

## 2026-07-03 — gate green; runtimes installed; push auth is flaky

- The verify gate (`host-lifecycle software --check .`) is green: both components at
  pin, all phase receipts recorded, prose clean, reconcile clean. The commit-msg hook
  blocks an ordinal tell in a message (tested: `phase 1` is rejected, exit 1).
- Tooling on this machine, all under `~/.local`: `bin/host-lint`, `bin/host-lifecycle`
  (v0.35.1), `bin/host-prove` (v0.3.0), `bin/allium` (3.5.0), `jdk-21/` (Temurin
  21.0.11), `share/tla2tools.jar` (v1.8.0, sha256 237332bd). The gate needs
  `host-prove` on PATH because host-lint's own `kani:` obligations surface once it is
  materialized as a component; the cheap gate probes `host-prove --help`, it does not
  run Kani.
- Two clearance details: the toolchain HAZARD (artifact with no toolchain) is waived by
  `repro-exempt = call/0002` on host-lint (consumed tool, not reproduced here); and
  `remap` is a `skip` receipt, not `done`, because `remap --check` errors on an empty
  or absent `.host-remap`, so a no-rename case-(a) adoption cannot pass a `done`
  recheck.
- Push auth to `connollydavid/agentic-UDPspeeder-simd` is intermittent: the stored
  credential is the `slartibardfast` token, which 403s after the first few pushes
  landed. If `git push` 403s, surface it to the operator rather than retrying or
  swapping credentials. As of this entry, `f8d36ed` and `5ec59af` are local only.

## 2026-07-03 — followed the host procedure: conformant, no upgrade available

- Ran the case-(c) upgrade/verify cycle from the `host` procedure
  (`github.com/connollydavid/host`). `host-template` upstream is still at `565410a`,
  the exact revision the `.host` stamp adopted: a `git fetch` in the submodule found
  no commits after it, and `565410a` is an ancestor of `origin/main`.
  `host-lifecycle upgrade .` reports up to date (baseline `46a1fd2`, 0 out of order).
  With no newer methodology to pull in, following the host reduced to the verify gate.
- Verify gate is green. `host-lifecycle software --check .` exits 0 (both components at
  pin, every phase receipt valid, reconcile clean, prose clean, no worktree-symlink
  hazards); `validate plan/` and `validate call/` both `ok`; `host-lint --all` and
  `--log` clean. Independently confirmed: udpspeeder-simd worktree is at pin `3374e3b`
  on `branch_libev` with a clean tree, host-lint at `78804cd`, and the commit-msg hook
  still rejects an ordinal tell (a `phase 1` message exits 1, a clean message exits 0).
- udpspeeder-simd still carries no `.allium`/`.tla` spec, so the requirements and timing
  lanes stay inert and there is no spec-without-lane defect. Every spec found on disk
  belongs to a tool's own worktree, not to the software under development.
- Standalone `host-lint --prose` on the authored docs prints advisory `note:` lines but
  exits 0. Those notes are below the enforced bar; the in-process prose audit inside
  `software --check` is the gate that binds and it reports no flagging or warning tropes.
  Most notes sit in verbatim copied-in content (the `UPGRADING.md` ledger,
  `cast/applying-personas.md`) that is not reworded locally. The notes are not a red gate.
- Corrects the 2026-07-03 "push auth is flaky" entry above: the commits it listed as
  local-only (`f8d36ed`, `5ec59af`) are now pushed. `HEAD == origin/main` and the tree
  is clean. Push auth may still 403 intermittently; surface it to the operator if it does.

## 2026-07-03 — embedded the packages feed as a second software lane

- Added `packages` (a fork of `openwrt/packages`, GPL-2.0, an OpenWrt feed of
  Makefiles/shell/C) as a Where-room component in `.host-software`: source pin
  `1d40ad9` on canonical branch `master`, no build/artifact (migrated build-recipe
  feed, not a built artifact). Materialized to `software/packages/master/`;
  `software --check` is green.
- Mechanics for a new component: host-lifecycle has no `software --add`, so a new
  lane is a hand-edited `.host-software` stanza plus `software --materialize --item
  <name> .` (the `--item` scope avoids re-touching existing worktrees). The embed and
  release phase receipts are written with `host-lifecycle receipt --record <phase>
  --component packages --disposition done|skip (--evidence|--reason) .`; a new
  component HAZARDs on missing embed+release receipts until both are recorded.
- Key rule (call/0003): commits in the packages worktree carry NO `Co-Authored-By:
  Claude` trailer, so the feed stays upstream-clean for `openwrt/packages`. The
  operator confirmed the scope is packages only, so host-repo commits keep the
  trailer. Recorded in call/0003 and the CLAUDE.md packages project-specifics.
