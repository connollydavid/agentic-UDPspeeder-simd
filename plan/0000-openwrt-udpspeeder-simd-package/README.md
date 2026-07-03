# Add an OpenWrt package for udpspeeder-simd

- Status: planned
- Persona: Ingrid (OpenWrt feed maintainer)
- Serves: https://github.com/openwrt/packages/issues/28562
- Scope: the `packages` and `udpspeeder-simd` components
- Package maintainer: David Connolly <david@connol.ly>
- Target: OpenWrt master for the first pull request; a release-branch backport is
  constrained by policy (see the rules below)
- Decisions: [`call/0004`](../../call/0004-udpspeeder-simd-package-coexists-and-links-dynamically.md)
  (coexist, dynamic linking), [`call/0005`](../../call/0005-cross-build-adjustments-live-in-the-fork.md)
  (build adjustments in the fork)

## Why

The issue at https://github.com/openwrt/packages/issues/28562 asks for the
performance-optimised UDPspeeder on low-end devices; the reporter's target is
`ath79/generic`, a MIPS 24Kc core. UDPspeeder-simd is that optimised fork. Rather
than repoint the existing `net/udpspeeder` package at a fork, this milestone adds a
separate `net/udpspeeder-simd` package that coexists with `udpspeeder`.

On `ath79` the gain comes from the portable word-width XOR and the portable
Reed-Solomon speedups, not from SIMD. The source carries no MIPS SIMD path, and
none is worthwhile on the 24Kc core (MSA is absent on that core, and its optional
DSP ASE targets fixed-point math rather than vector XOR).

## OpenWrt maintainer rules this milestone follows

From the feed's `CONTRIBUTING.md` (pinned in the packages worktree) and
https://openwrt.org/docs/guide-developer/packages :

- Pin the source to a fixed commit or tag with a `PKG_MIRROR_HASH`, never a branch
  head or a "latest" archive. This is also what the issue requests.
- `PKG_MAINTAINER` is a real name and a real, public email (David Connolly
  <david@connol.ly>). A GitHub noreply address is rejected.
- `PKG_LICENSE` is the SPDX identifier `MIT`, with `PKG_LICENSE_FILES` naming the
  license file (`LICENSE.md`) in the fork.
- `PKG_RELEASE` starts at 1.
- No dependencies outside the OpenWrt core packages or this feed.
- Each pull-request commit subject is prefixed with the package name
  (`udpspeeder-simd: add package`) and carries a `Signed-off-by` that matches the
  author (a real name and a public email), with no automated co-author trailer
  (the packages rule in [`call/0003`](../../call/0003-no-claude-co-author-trailers-on-packages.md)).
  The sign-off is the DCO, which is separate from the co-author trailer.
- A `test.sh` beside the Makefile lets the OpenWrt CI runtime-test the package on
  its supported architectures.
- Release branches (`openwrt-XX.YY`) take only security and bug fixes. Adding a new
  package to a release branch is against policy, so a backport is not a routine
  cherry-pick (see `#backports`).

## Design decisions

- Interop (`call/0004`): a distinct package `udpspeeder-simd` with distinct paths
  (`/usr/bin/udpspeeder-simd`, `/etc/config/udpspeeder-simd`,
  `/etc/init.d/udpspeeder-simd`), no file clash with `udpspeeder`, no `CONFLICTS`.
- Linking (`call/0004`): dynamic, with `DEPENDS` on the shared libraries the binary
  needs, like the existing `udpspeeder`. No static build. A static C++ binary is
  larger on flash, which works against the low-end devices this issue targets, and
  static linking runs against OpenWrt's shared-library model.
- Build adjustments (`call/0005`): they live in the fork's makefile, after which the
  `.host-software` pin is updated. The fork commits keep the normal sign-off and
  co-author trailer; only the packages repo drops the trailer. In practice no fork
  change was needed: the feed's `cc_cross` and gitversion Build/Prepare sufficed.
- SDK for local validation: the public prebuilt x86_64 snapshot SDK (the one OpenWrt
  CI uses), not a from-source build (`make world` proved excessive for this). The
  embedded `openwrt` component stays but is not required for this path. Local
  validation covers x86_64; multi-architecture, including `ath79/generic`, runs in
  the CI lane. Snapshot OpenWrt packages are `.apk`, not `.ipk`.

## Build sequence

### Make the fork build cleanly across architectures {#fork-build}

- verify: attested operator

### Author the udpspeeder-simd feed package Makefile {#feed-package}

- depends: #fork-build
- verify: attested operator

### Author the service integration {#service-integration}

- depends: #feed-package
- verify: attested operator

### Add the runtime test script {#test-script}

- depends: #feed-package
- verify: attested operator

### Add the OpenWrt SDK build lane to CI {#ci-sdk-lane}

- depends: #feed-package
- verify: attested operator

### Confirm polite interop with the udpspeeder package {#interop}

- depends: #service-integration
- verify: attested operator

### Open the pull request to OpenWrt master {#pr}

- depends: #interop, #test-script
- verify: attested operator

### Evaluate a release-branch backport under policy {#backports}

- depends: #pr
- verify: attested operator
