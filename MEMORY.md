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

## 2026-07-03 — push-auth root cause: slartibardfast is pull-only; helper is `store`

- The recurring push 403 has a concrete root cause rather than flakiness.
  `gh api repos/connollydavid/agentic-UDPspeeder-simd` shows the `slartibardfast`
  account has `push: false` (pull only); the owner account `connollydavid` (also
  logged in to gh) has push. And git's credential helper here is `store`
  (`~/.git-credentials`), not gh, so `gh auth switch -u <user>` does not change the
  token `git push` sends. The store already holds slartibardfast's token, so pushes
  go out as slartibardfast and are denied.
- To push as slartibardfast (the operator's intended identity), grant slartibardfast
  write on the repo; then a plain `git push` works with no helper change. To make
  `gh auth switch` actually route pushes, run `gh auth setup-git` so git uses the
  active gh account's token. Do not push as connollydavid without operator direction:
  it changes the public push identity, and the operator is provenance-sensitive.
- Pending operator decision (asked, away from keyboard): grant slartibardfast write,
  push as connollydavid, or operator pushes manually. As of this entry `main` is ahead
  by 7 unpushed commits (packages embed, call/0003, CLAUDE.md, two memory entries, the
  earlier verify-sweep entry, and the three-persona commit).

## 2026-07-03 — resolved: push as connollydavid via a one-shot gh credential

- Operator chose to push as the owner. The working recipe: `gh auth switch -u
  connollydavid`, then
  `git -c credential.helper= -c credential.helper='!gh auth git-credential' push origin main`.
  The empty `credential.helper=` resets the inherited `store` helper (which holds
  slartibardfast's read-only token and 403s), and the gh helper then supplies
  connollydavid's token for that one push, with no change to global git config.
- All pending commits landed (`23bdc1f..6f1e66a`); `main` is in sync with origin.
- Going forward: repeat that one-shot override, or run `gh auth setup-git` once (with
  connollydavid active) and clear the stale store token so a plain `git push` works.
  slartibardfast stays read-only on the repo (not a collaborator); grant it write only
  if a bot-identity push is wanted later. This supersedes the earlier "push auth is
  flaky" framing: the cause was permissions plus a static store token, not flakiness.

## 2026-07-03 — published the book to GitHub Pages

- Ran the publish phase. `host-lifecycle book .` (v0.35.1) writes book.toml with
  `src = mdBook/src` and `build-dir = mdBook/out`, a SUMMARY in lifecycle order, and 17
  pages; `book --check .` passes (every room renders: cast 5, plan 1, software 1, call 4,
  reference 4, memory 1). book.toml and mdBook/ are gitignored generated output.
- Fixed two defects in the reference doc-site workflow. It was named `site.yml`, but the
  publish-phase recheck is `test -f .github/workflows/mdbook.yml`, so a `done` publish
  receipt would HAZARD until the file is named `mdbook.yml`. It also published `./book`,
  while v0.35.1 builds to `mdBook/out`. Renamed to mdbook.yml, set
  `publish_dir: ./mdBook/out`, and corrected the stale `src=docs` comment. Both look like
  template bugs at revision 565410a, worth proposing upstream.
- CI (`mdbook.yml`, on push to main) builds with mdbook v0.4.40 and deploys mdBook/out to
  the `gh-pages` branch via peaceiris/actions-gh-pages. GitHub Pages was disabled (the
  `/pages` API returned 404), so enabled it from gh-pages root with
  `gh api -X POST repos/connollydavid/agentic-UDPspeeder-simd/pages -f source[branch]=gh-pages -f source[path]=/`.
  The site is live at https://connollydavid.github.io/agentic-UDPspeeder-simd/ (HTTP 200).
- Publish receipt flipped from skip to done; `software --check` is green (the recheck now
  finds mdbook.yml). Verified locally with the pinned mdbook v0.4.40 before pushing.

## 2026-07-03 — udpspeeder-simd package builds clean against the x86_64 SDK

- SDK approach pivoted. `make world` was excessive; used the public prebuilt x86_64
  snapshot SDK (openwrt-sdk-x86-64_gcc-14.4.0_musl, the one OpenWrt CI uses) rather than a
  from-source build. The embedded `openwrt` component stays but is not needed for this path
  and adds ~2.5 min to `software --check` (flagged for the operator to keep or remove).
- OpenWrt needs a case-sensitive FS: /mnt/c is case-insensitive and the build refuses it,
  so software/openwrt is symlinked to ext4 (/home/dconnolly/host-stores); the SDK and its
  build_dir also live on ext4.
- The package (net/udpspeeder-simd, authored in the packages worktree) built cleanly:
  `make package/udpspeeder-simd/compile` produced udpspeeder-simd-2026.07.03~3374e3bb-r1.apk
  (snapshot uses .apk, not .ipk). No fork change was needed — the udpspeeder-style cc_cross
  + gitversion Build/Prepare sufficed, and the makefile's `export STAGING_DIR=/tmp/` did not
  break it. Dynamic linking confirmed by deps libc/libstdcpp6/librt/libatomic1.
  PKG_MIRROR_HASH = 225c0fef087e56c190ec1a626fc244a0e32f1f791d5e22efe604e962026c4698.
- Task receipts done: #fork-build, #feed-package, #service-integration. Pending: #test-script
  (CI runs it), #ci-sdk-lane, #interop, #pr, #backports. The package files are authored in the
  packages worktree but NOT yet committed or pushed to the fork; the branch strategy and the
  outward push/PR await operator go.

## 2026-07-03 — udpspeeder-simd pushed to the fork on a feature branch (PR held)

- Operator chose fork + PR, but the PR needs a review round, so it is NOT opened. Committed
  net/udpspeeder-simd/ (Makefile + files + test.sh) on branch `udpspeeder-simd` of
  connollydavid/packages, commit db858a8, pushed. Author + DCO Signed-off-by = David Connolly
  <david@connol.ly> (real name + public email, no Claude trailer, per call/0003 + OpenWrt rules).
  Subject "udpspeeder-simd: add package"; body references
  https://github.com/openwrt/packages/issues/28562.
- The packages worktree had no git identity; set it to David Connolly / david@connol.ly. The
  canonical master worktree was used in-place to make the branch then restored to master @
  1d40ad9, so the .host-software pin and software --check stay intact; the feature branch lives
  on the fork, not as a host-tracked worktree.
- Open the PR (after review) from
  https://github.com/openwrt/packages/compare/master...connollydavid:packages:udpspeeder-simd?expand=1
  Before submitting, consider syncing the fork onto current openwrt/packages master (the branch
  is based on the fork's master 1d40ad9, which may be behind upstream).
- openwrt embed KEPT (operator decision), despite the ~2.5 min software --check cost.
- Receipts: #fork-build/#feed-package/#service-integration/#interop done; #pr held (review round);
  #test-script + #ci-sdk-lane pending (CI); #backports policy-constrained.
- Update: rebased the branch onto current upstream openwrt/packages master (333bf60); tip is now
  a7f0f087, a single commit with no merge commits in the PR range; force-pushed to the fork.
  Formalities self-check (against .github/formalities.json) passes: crlf=0, subject 28<=60,
  body<=79, DCO Signed-off-by matches a non-noreply author, conffiles declared, openwrt-meta
  present, no patches. Open review-round items: Run Testing details (built x86_64 via the
  snapshot SDK gcc-14.4.0 + CI test.sh; a physical-device run is optional but stronger), and a
  release-notes line if the formalities bot requests one.

## 2026-07-03 — PR opened to openwrt/packages (pull/29901)

- Opened https://github.com/openwrt/packages/pull/29901 ("udpspeeder-simd: add package") as
  connollydavid, from connollydavid:udpspeeder-simd to openwrt:master, referencing the issue.
  Confirmed host-side clean first: main == origin, fork branch a7f0f087 synced, four receipts
  done. Release notes are in the PR body (a section), testing framed as x86_64 build + CI
  test.sh (operator accepted that trade-off).
- Corrected the plan: #pr no longer depends on #ci-sdk-lane. The operator directed opening the
  PR against OpenWrt's own CI, so the fork-side SDK CI lane is independent, not a prerequisite.
  Recorded #test-script done (script added + wired; the PR CI exercises it) and #pr done.
  Pending: #ci-sdk-lane (fork-side, optional) and #backports (policy: new packages are not
  normally backported to release branches).
- Next: watch the PR's FormalityCheck + multi-arch build. If the bot wants release notes in a
  different form, amend and force-push the fork branch.

## 2026-07-03 — addressed the Copilot review; fork version-banner fix; idiomatic test.sh

- Copilot flagged two on PR 29901, both valid: test.sh could false-positive (its grep matched
  the program name, which a dynamic-loader error echoes), and the init had `fix_latency`
  non-local plus a duplicated `sock_buf`. Both init issues were inherited verbatim from
  net/udpspeeder (the sibling has the same bugs). @codemarauder is Nishant Sharma, the
  net/udpspeeder maintainer; offered him co/primary maintainership of udpspeeder-simd in the
  PR comment.
- Idiomatic gap and its fix: OpenWrt test.sh idiomatically greps the package version, but the
  binary's print_help() truncated gitversion to 10 chars (`strncpy(...,10)`), so a full-version
  grep would miss. Fixed the fork (main.cpp copies the full string; commit 2e12e5b pushed to
  branch_libev), re-pinned .host-software to 2e12e5b, updated the package (PKG_SOURCE_VERSION
  2e12e5b, PKG_MIRROR_HASH 6d4564dc, PKG_VERSION now 2026.07.03~2e12e5b4), and switched test.sh
  to `grep -qF "$PKG_VERSION"`. Amended the single PR commit (7f5bc7c8), force-pushed; PR still
  discrete (4 files). Posted a terse reply comment (#issuecomment-4877656043).
- Rebuilt via the SDK (exit 0) for the new hash. The runtime version-grep is confirmed by
  OpenWrt's PR CI, since the cross-built musl binary cannot run on this host.
- Scope decision: we will NOT touch net/udpspeeder (operator). Removed the "happy to send a
  separate PR" offer from the PR comment (edited #issuecomment-4877656043); the sibling's same
  two init bugs are left alone.

## 2026-07-03 — OpenWrt PR #29901: 32-bit ARM build fix in the fork

- The PR's multi-arch CI (openwrt shared `Feeds Package Test Build`) ran and failed
  only on `arm_cortex-a15_neon-vfpv4` and `arm_cortex-a9_vfpv3-d16`; aarch64, mips_24kc,
  x86_64, i386, powerpc, riscv64 all passed. Root cause was in the fork source, not the
  package: `xor_spe.S` marked the stack non-exec with `.section .note.GNU-stack,"",@progbits`.
  On 32-bit ARM `@` starts a line comment, so gas ate `@progbits` and reported "junk at
  end of line, first unrecognized character is `,`". aarch64/mips/ppc/riscv/x86 do not use
  `@` as a comment char, which is why only 32-bit ARM broke.
- Fix (universal, per call/0005 — build adjustments live in the fork): spell it
  `%progbits`. gas accepts `%` for the ELF section type on every target (verified locally:
  x86 g++ assembles both `@progbits` and `%progbits`), and `%` is the required form where
  `@` is a comment. Fork commit `c2b3759` on `branch_libev`.
- Propagation: re-pinned `.host-software` udpspeeder-simd → c2b3759; bumped the PR's
  `net/udpspeeder-simd/Makefile` PKG_SOURCE_VERSION → c2b37590 and refreshed
  PKG_MIRROR_HASH → d6f564823fa0217788bc937e06c71266bfa3a457d0803912b2d10bcb9957d3ba
  (amended the single PR commit, force-pushed; PR head 5d8ed050). Kept the fork commit's
  Claude co-author trailer; the packages commit has none (call/0003).
- Mirror-hash regen recipe (local x86_64 SDK): set PKG_MIRROR_HASH to 64 zeros, run
  `make package/<pkg>/download V=s`; the download clones, packs the reproducible git
  tarball, and prints `got <real-hash>`. `skip` does NOT work for a git-proto source
  (the github archive downloader refuses without a real sha256). Then compile to confirm.
