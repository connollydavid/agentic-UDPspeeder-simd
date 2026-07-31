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

## 2026-07-17 — OpenWrt PR #30015 (net/udpspeeder) + timeout fold into PR #29901

- Opened https://github.com/openwrt/packages/pull/30015 (net/udpspeeder) against
  openwrt/packages:master from connollydavid/packages:udpspeeder-toolchain-flags. Two atomic
  commits, PKG_RELEASE 3→4→5:
  - `udpspeeder: build with the toolchain CXX and flags`: new patch
    010-build-with-toolchain-flags.patch builds the cross target with $(CXX) and honours
    $(CXXFLAGS)/$(LDFLAGS), makes gitversion overridable; package drops the Build/Prepare sed
    hacks, injects the version via MAKE_FLAGS, adds PKG_BUILD_FLAGS:=no-mips16.
  - `udpspeeder: pass the timeout option to the binary`: adds
    `procd_append_param command --timeout "${timeout}"` after --mtu in files/udpspeeder-init.
    `Fixes: .../issues/18955` auto-closes on merge. The option was validated and shipped in the
    sample config (tunnel2) but never passed to the binary.
- no-mips16 is REQUIRED, not cosmetic: honouring CXXFLAGS pulls -mips16 onto
  mips_24kc/mipsel_24kc, where C++ std::atomic emits a `sync` barrier MIPS16 cannot encode
  ("opcode not supported on this processor: mips2 (mips2) 'sync'"); no-mips16 strips it (MIPS32).
- Non-drift confirmed from binary help: `--timeout ... unit: ms, default: 8ms`; UCI schema
  default is 8, so wiring it is a no-op at the default and just makes the advertised option work.
- Verified locally via snapshot SDK on all ten CI arches (scratchpad/build_all.sh): all pass;
  both mips controls (without no-mips16) fail on the sync opcode, proving necessity.
- PR #29901 (net/udpspeeder-simd) had the identical latent timeout bug. Folded the same
  `--timeout` line into the single `udpspeeder-simd: add package` commit (amend, NO PKG_RELEASE
  bump since 1.0.0-1 is unreleased); force-pushed connollydavid:udpspeeder-simd → 3540c71ce.
  Posted a terse alignment comment (#issuecomment-5002468098) referencing #30015.
- Hygiene: packages commits carry NO Claude trailer (call/0003); sign-off = author = David
  Connolly <david@connol.ly>. #30015 rebased onto current upstream/master (net/udpspeeder
  untouched upstream); #29901 left on its older base (PR diff is clean vs merge-base and CI
  builds on the snapshot SDK, so no rebase needed and none requested). .host-software NOT
  re-pinned (feature-branch work; the master pin is unchanged).

## 2026-07-17: #30015 "Dirty patches detected" — patches must be quilt-refreshed

- All ten Feeds Package Test Build jobs failed at `make package/udpspeeder/refresh`: the CI
  requires each patch byte-identical to quilt's canonical output. Our patch applied at exact
  offsets with no fuzz, yet still failed.
- Root cause: OpenWrt refreshes with `QUILT_DIFF_OPTS="-p" quilt --quiltrc=- refresh -p ab
  --no-index --no-timestamps` (openwrt/openwrt include/quilt.mk), and GNU diff `-p` appends
  function context to hunk headers (`@@ -51,7 +51,7 @@ cygwin:git_version`). `git format-patch`
  output lacks the suffix, so the refresh rewrites the file and the git-diff check trips.
- Fix recipe: extract the pinned source (`git archive 20230206.0`), set up `patches/` + series,
  `quilt --quiltrc=- push -a`, run the refresh command above, copy the refreshed patch back.
  Verified idempotent: a second refresh reports "is unchanged". Quilt preserves the git header
  (From/Subject/Signed-off-by/diffstat) untouched.
- Folded into the toolchain commit via `commit --fixup` + `GIT_SEQUENCE_EDITOR=: git rebase -i
  --autosquash`; range-diff showed only the two hunk-header lines changed, timeout commit
  byte-identical (`=`). Force-pushed `7a76af810...075f4a7e0` (lease + force-if-includes).
- Lesson: any patch destined for openwrt/packages should be generated or round-tripped through
  quilt with those exact args before committing, not taken raw from git format-patch.

## 2026-07-31 — upstream merged our toolchain-flags PR; taking it in both packages

- wangyu-/UDPspeeder merged https://github.com/wangyu-/UDPspeeder/pull/356 (686d6079), then
  reshaped it in b6a1b594: `cross` was restored to the hardcoded `${cc_cross}`, and the change
  landed as a NEW target instead:
  `cross_cxx: ${CXX} -o ${NAME}_cross -I. ${SOURCES} ${FLAGS} -O2 ${CXXFLAGS} ${LDFLAGS} ${LDLIBS}`.
  Three deltas vs what we sent: `-O2` moved BEFORE `${CXXFLAGS}` (so a caller's -Os wins instead
  of being overridden), `-lrt` dropped, `${LDLIBS}` added. Our `gitversion ?=` hunk survived
  verbatim, so MAKE_FLAGS version injection still works.
- Consequence for the merged net/udpspeeder patch: its second hunk (the `gitversion ?=` line) can
  no longer apply to any source at or past b6a1b594, since upstream already has it. So the patch
  had to be dropped as part of a version bump, not deferred.
- `-lrt` is a no-op on OpenWrt, PROVEN not assumed: musl's `librt.a` in the toolchain is an 8-byte
  empty archive (clock_gettime is in libc), and the packaged binary built with `LDLIBS="-lrt"` and
  without it are byte-identical (sha256 502163f5...). NEEDED is libstdc++/libgcc_s/libc either way.
  So neither package passes -lrt; a toolchain that needs it can pass LDLIBS. Left `DEPENDS:=+librt`
  alone in both (inert: musl's libc provides it) rather than widen the diff.
- The 3-year source bump 20230206.0 -> b6a1b594 is WIRE-SAFE, also proven: the only functional
  change is swapping the in-tree `crc32h` for Stephan Brumme's `crc32_fast`. Both are standard
  zlib CRC-32 (poly 0xEDB88320, init ~0, final complement); a comparison harness over every length
  0..2048 x 8 random buffers matched exactly, and both give 0xCBF43926 for "123456789". The rest is
  typo fixes, an `is_vaild`->`is_valid` rename, and a djb2/sdbm loop rewrite that removes a
  one-byte over-read without changing the hash.
- OpenWrt version convention for an untagged git source is `<base>~<shortsha>` + a full-sha
  PKG_SOURCE_VERSION. Careful: `~` sorts BEFORE end-of-string (Debian style), so `20230206.0~<sha>`
  would sort BELOW the released 20230206.0 and break the upgrade path. Used `20260731~b6a1b594`
  (commit date as base) so it sorts above.
- Fork: added the same `cross_cxx` target (commit 81fde6c, tagged v1.0.1, pushed); kept our
  cross/cross2/cross3 as-is since this fork deliberately dropped the hardcoded compiler paths.
  Re-pinned .host-software to 81fde6c.

## 2026-07-31 — correction: PR #29901 has no test.sh (the 2026-07-03 entry is wrong)

- The 2026-07-03 entry above says "#test-script done ... test.sh added beside the Makefile;
  exercised by the OpenWrt PR CI runtime test", and `.host-task-receipts` records the same
  evidence for `plan/0000#test-script`. Both are FALSE as of now, and have been since 2026-07-04.
- Traced through the branch reflog: test.sh survived to b7ef6490 (2026-07-04 21:31) and was gone
  in the very next amend, b9e331ec (2026-07-04 23:16), the one that fixed the Build/Prepare
  double-expansion. It was dropped accidentally, not by decision, and every later force-push
  carried the loss forward. The PR head has carried three files (Makefile, config, init) ever
  since, so the CI arches flagged `runtime_test: true` have had nothing to run.
- Operator decision on 2026-07-31: LEAVE IT OUT rather than restore it, so the package ships
  without a runtime test. BKPepe had questioned the script anyway ("Do we need this script at
  all? This should be covered by generic testing"). The `#test-script` receipt is therefore
  stale and should be re-dispositioned by the operator (it is a tool-written ledger; not
  hand-edited here).
- Lesson: an amend that fixes one file can silently drop another. Diff the file LIST against the
  PR head after every amend + force-push, not just the file contents.

## 2026-07-31 — OpenWrt packaging idioms, and how to test under qemu properly

- VERSION FORM for an untagged git source: do NOT hand-write PKG_VERSION. Set PKG_SOURCE_DATE
  plus a full-sha PKG_SOURCE_VERSION and let include/download.mk derive it:
  `PKG_VERSION := $(subst -,.,$(PKG_SOURCE_DATE))~$(call version_abbrev,$(PKG_SOURCE_VERSION))`,
  giving `2026.07.31~b6a1b594` (version_abbrev = 8 chars; it returns the FULL sha under DUMP, so
  the feed index shows the long form while the build uses the short one). Feed usage: 96 packages
  use PKG_SOURCE_DATE vs 3 that hand-write a `~` version. Changing the version form changes
  PKG_MIRROR_HASH, since the tarball's inner subdir is $(PKG_NAME)-$(PKG_VERSION).
- UPSTREAM UDPspeeder TRUNCATES THE VERSION: print_help does `strncpy(buf, gitversion, 10)`, so
  `--help` (the flag OpenWrt's generic check finds) shows ten characters only. The old version
  `20230206.0` was ten characters exactly, so the check passed by luck for years. Any longer
  version needs `test-version.sh`, the idiomatic override (70 in the feed). Our simd fork already
  prints the full version, so only net/udpspeeder needs the override.
- DEPS ARE DERIVED FROM THE ELF: include/package-pack.mk runs scripts/gen-dependencies.sh, which
  reads NEEDED and FAILS the build for a linked library that is not declared. It never checks for
  extras, so a declared-but-unlinked dep is inert. librt and libatomic were both provably inert:
  70/70 builds and packet tests across all 35 published architectures with both removed, no binary
  NEEDs either, and no `__atomic_*`/`__sync_*` symbol anywhere. On musl, Package/librt/install
  copies nothing at all (`ifneq ($(CONFIG_USE_MUSL),y)`).
- RUNTIME TESTS, the idiom: `test.sh <pkgname> <version>` runs INSIDE a target-arch container
  (binfmt + qemu-user-static) with the package installed. `pre-test.sh` installs test deps
  (`apk add socat`). A package-specific test.sh REPLACES the generic tests (version check
  included), and test-version.sh is only consulted by the generic path, so test.sh must assert the
  version itself. BusyBox in OpenWrt is built with NC_SERVER=n and NC_EXTRA=n, so nc can neither
  listen nor exec: use socat via pre-test.sh. Do not use a fixed sleep, the container is emulated;
  retry the payload instead.
- QEMU CPU MODELS, do not trust the default. powerpc_8548 (CPU_TYPE 8548, e500v2) fails under the
  default 32-bit PPC model with an illegal instruction, and it is NOT the package: the faulting
  word disassembles to `iseleq` inside musl libc, which holds 63 isel instructions while our
  binaries hold none. `-cpu e500v2_v10` runs it. Control: the musl loader alone faults under the
  default and prints its version under e500v2_v10. Every arch now names a verified model in
  .github/scripts/arch-map.tsv; where qemu-user lacks the exact CPU the closest SUPERSET is used
  (xscale and fa526 -> arm926, cortex-a5 -> cortex-a7, pentium-mmx -> pentium2, pentium4 -> n270,
  since a weaker model invents failures and a richer one hides them and skews feature detection).
- PROBE BY OUTPUT, NOT EXIT STATUS: musl's loader prints its version and exits 1. A first pass at
  CPU discovery keyed on exit status and reported every architecture broken. Judge the output.
- SCOPE: OpenWrt's CI runtime-tests only aarch64_generic, arm_cortex-a15_neon-vfpv4,
  i386_pentium-mmx, mips_24kc and x86_64; powerpc_8548 is runtime_test:false. So the CPU-model
  work is OUR local lane's concern, not something the OpenWrt PR depends on.
- arm_fa526 (gemini) is BUILD-ONLY under qemu-user, and the cause is the emulator, not the
  package. That target compiles plain ARMv4: its binary holds ZERO bx/blx, where the ARMv5 build
  of the same package holds 133, so it cannot enter Thumb code at all. qemu-user always maps a
  Thumb vdso, so the call to __vdso_gettimeofday runs Thumb bytes in ARM state and branches to a
  wild address; the in_asm trace ends in `IN: __vdso_gettimeofday` decoding 46c046c0 (Thumb
  nop;nop) as ARM and branching to 0x40b2838c, exactly the SIGSEGV si_addr. Proven not ours two
  ways: the CURRENTLY SHIPPED 20230206.0 package fails identically under -cpu arm926, and a
  trivial C++ program against the same musl and libstdc++ runs fine there. Real hardware never
  meets it, since the Linux ARM vdso needs ARMv7 and a gemini kernel supplies none, leaving musl
  on plain syscalls. qemu-user has no flag to withhold the vdso, so the packet test is skipped
  for that arch rather than run under a v7 model that would hide real mismatches.

## 2026-07-31 — udpspeeder-simd crashed on x86_64 without SSSE3 (found by faithful qemu models)

- lib/fec.cpp initialised `addmul1_x86_fn = addmul1_ssse3` and only ever RAISED it to AVX2 or
  AVX-512. Nothing probed SSSE3, and x86_64 does NOT imply it: AMD K8/K10 (Athlon 64, Opteron,
  Phenom, Phenom II, Athlon II) lack it, as do early 64-bit Intel parts; AMD added it with
  Bulldozer in 2011. Those CPUs took SIGILL on the first PSHUFB in the Reed-Solomon inner loop,
  so the tunnel died on its first FEC batch. Upstream udpspeeder was unaffected.
- Only visible under a faithful CPU model. Every earlier sweep used qemu's DEFAULT x86_64 model
  (rich), and OpenWrt's own CI runtime-tests x86_64 on a GitHub runner that has SSSE3/AVX2, so the
  bad path never ran. It appeared the moment the map named `-cpu qemu64` (the AMD64 baseline).
- Fix (fork v1.0.2, f3834047): pointer starts at scalar and rises only as CPUID allows, via
  cpu_has_ssse3() (leaf 1 ECX bit 9) and cpu_has_sse2(); new SSE2 addmul1 sits beneath SSSE3, so a
  CPU without PSHUFB still vectorises. SSE2 has no byte shuffle, so it multiplies by repeated
  doubling: `_mm_add_epi8(x,x)` for the shift and `_mm_cmpgt_epi8(0,x)` to select the reduction.
  The reduction constant is read from `gf_mul_table[2][0x80]`, not hardcoded, so it follows the
  field. Measured 1.73x scalar at 1500B (913 vs 1579 ns); ssse3 is 9.8x.
- Also hardened packet_cook.cpp: its AVX2 tier was set from CPUID leaf 7 EBX bit 5 ALONE, with no
  OSXSAVE/XCR0 check and no max-leaf check. Now mirrors the correct probe.
- Test method worth reusing: `bench_addmul1_force(name)` pins one implementation so test_fec can
  hold EVERY path against scalar over all 256 multipliers and sizes hitting each loop and tail.
  Ran the suite under `qemu-x86_64 -cpu qemu64|Nehalem|Haswell` to exercise sse2/ssse3/avx2.
  AVX-512BW cannot be verified this way: qemu-user leaves ZMM state disabled in XCR0, so the
  OS-support check correctly declines it.
- HARNESS BUG worth remembering: `find ... | head -1` picked a STALE build dir from an earlier
  session in a reused SDK, so one x86_64 result described a binary nobody had built that run.
  Select by newest mtime (`-printf '%T@ %p'| sort -rn`). Fresh CI SDKs never hit this; local
  reused SDKs do.

## 2026-07-31 — qemu64 is not the x86_64 floor; the first Opteron is

Asked whether we are aligned with the very first x86_64 chip, and the honest answer needed
evidence at both ends rather than an assertion. Findings worth keeping:

- `-cpu qemu64` GRANTS SSE3. It caught the SSSE3 crash, but it is not the architectural floor and
  never was. The floor is `-cpu Opteron_G1,-sse3`: qemu's model of the AMD Opteron 240 of 2003,
  the first x86_64 silicon, with SSE3 subtracted for the earliest stepping. SSE3 only arrived on
  K8 revision E in 2005. The arch map's x86_64 row now names that model.
- Compile-time floor is already right: the OpenWrt x86_64 toolchain defaults to `-march=x86-64`
  with sse3, ssse3, sse4, cx16 and popcnt all DISABLED (`gcc -Q --help=target` proves it, and
  `CONFIG_TARGET_OPTIMIZATION` is only `-Os -pipe`, so nothing raises it).
- `XGETBV` IS NOT BASELINE. It arrived with XSAVE in 2008, so a K8 faults on it. Our probes check
  CPUID leaf 1 ECX bit 27 (OSXSAVE) first, and the EMITTED code keeps the order: every xgetbv sits
  behind `bt $0x1b,%ecx` / `jae`. Verified in the disassembly, not just the source. Worth
  re-checking after any compiler bump, since the guard is a branch the optimiser could in
  principle move.
- CRC32C's hardware path is behind `crc32c_has_hw()` (leaf 1 ECX bit 20, SSE4.2) and falls back to
  the slicing-by-8 table, so it is safe on K8 too.
- Static screen worth reusing, the x86 analogue of isa-check.sh: disassemble and list every
  mnemonic outside the baseline together with its containing function. `udpspeeder` holds ZERO;
  `udpspeeder-simd` confines all of them to `addmul1_{ssse3,avx2,avx512}`, `xor_tile_{avx2,avx512}`
  and `crc32c_hw`, each reached only through CPUID. That is the property to hold, not "it ran".
- Dynamic proof: both packages pass the packet test under `Opteron_G1` and `Opteron_G1,-sse3`, and
  test_udpspeeder under those models selects sse2 and agrees with scalar over all 256 multipliers,
  declining ssse3/avx2/avx512bw.
- Reading tests through a grep can invent a hollow section: filtering on "addmul1" hid the tier
  results, whose pass lines read "sse2 agrees with scalar". Read the section, not a keyword.

## 2026-07-31 — the x86 lacuna: OpenWrt has three x86 package arches, not one

Asked whether x86 coverage is complete. It was not, and the gap was in the emulation models
rather than in the architecture list.

- OpenWrt publishes FOUR x86 subtargets (64, generic, geode, legacy) but THREE package
  architectures. geode and legacy declare no CPU_TYPE, so both fall to the i386 default of
  `pentium-mmx` (include/target.mk). One row covers the pair; generic is pentium4; 64 is x86_64.
- BOTH i386 models were too rich, the same failure as qemu64 on x86_64:
  - `n270` (Atom) HAS SSSE3, so the i386_pentium4 job selected the SSSE3 path and never once ran
    the SSE2 tier a real Pentium 4 uses. Now `pentium3,+sse2`, which is exactly a P4's ISA.
  - `pentium2` HAS CMOV, which a Geode GX/LX and a Pentium MMX do not. Now `pentium,+mmx`.
- qemu-user genuinely gates these, proven by one-instruction controls rather than assumed:
  `pentium2` runs cmov and faults on pshufb; `pentium2,-cmov` and `pentium,+mmx` fault on cmov;
  `n270` runs BOTH cmov and pshufb; `pentium3,+sse2` runs movdqa and faults on movddup. Feature
  subtraction/addition on a stock model works, so compose the model instead of borrowing one.
- Static screen of the geode build: nothing above the floor outside CPUID-guarded functions. The
  one CMOV lives inside `addmul1_ssse3`, which GCC is free to emit because `target("ssse3")`
  implies P6, and it only ever runs on a CPU that has SSSE3 and therefore CMOV. Not a defect.
- All three x86 arches pass both packages under the tightened models.
- `mips_4kec` and `riscv64_riscv64` DO have package directories on the buildbot, so the listing
  alone suggests 37 arches. They are frozen: last built April and July of 2025 against zlib 1.3.1,
  where a live arch carries a build from this month. Check the DATES, not the directory.
