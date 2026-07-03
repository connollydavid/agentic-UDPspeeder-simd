# Ingrid (OpenWrt feed maintainer)

Ingrid maintains the `packages` feed and packages UDPspeeder-simd and its
dependencies for OpenWrt, so router users install the tunnel with `opkg`.

## Goals

- Package UDPspeeder-simd cleanly for the feed, with correct dependencies such as
  libev, so it installs on a stock OpenWrt device.
- Build the tunnel across the OpenWrt target architectures the feed supports.
  UDPspeeder-simd ships hand-written SIMD assembly (`xor_spe.S`) and CPU-specific
  optimisation, so she confirms the package builds on MIPS, ARM, and x86, or falls
  back to a portable path where the SIMD one is unavailable.
- Provide the OpenWrt service glue that upstream lacks. Upstream ships a raw
  command-line binary, so she adds an init script and a UCI configuration wrapper
  that let an administrator run the tunnel as a managed service.
- Keep the feed building across the supported OpenWrt release branches (for
  example `openwrt-24.10` through the current development branch), and bump the
  Makefile version and source hash when a new upstream release lands.
- Offer fixes back to `openwrt/packages` with no rework, so authorship and commit
  style stay clean for the community feed.

## Personalization and technical ability

An experienced package maintainer, fluent in the OpenWrt build system, Makefile
feeds, and the feed layout. She reviews a steady stream of contributions and holds
them to reproducible, hermetic builds and correct license metadata. She works
several release branches at once, and she reads a diff for upstream-cleanliness
before she forwards it.

## Scenarios

- A new UDPspeeder-simd release lands. Ingrid bumps the feed Makefile version and
  source hash, builds the package for a MIPS target and an ARM target, and confirms
  it installs and runs on a test device.
- A contributor opens a change to the feed. Ingrid checks it applies cleanly and
  carries no automated co-author trailer (see
  [`call/0003`](../call/0003-no-claude-co-author-trailers-on-packages.md)) before
  she offers it to `openwrt/packages`.

## Priority

Primary persona for the packages lane. The feed exists to let her ship the software
to OpenWrt users, so her packaging interface (the Makefiles and the service glue)
and her upstream-clean workflow drive the lane's work.

*Grounded in the role and the UDPspeeder-simd source. Refine further by discussion
with the operator (see [applying-personas.md](applying-personas.md)).*
