# Ingrid (OpenWrt feed maintainer)

Ingrid maintains the `packages` feed and packages UDPspeeder-simd and its
dependencies for OpenWrt, so router users install the tunnel with `opkg`.

## Goals

- Package UDPspeeder-simd cleanly for the feed, with correct dependencies, so it
  installs on a stock OpenWrt device.
- Keep the feed building across the supported OpenWrt release branches (for
  example `openwrt-24.10` through the current development branch).
- Offer fixes back to `openwrt/packages` with no rework, so authorship and commit
  style stay clean for the community feed.
- Follow new upstream releases of the software and bump the feed Makefiles with
  the right version and source hash.

## Personalization and technical ability

An experienced package maintainer, fluent in the OpenWrt build system, Makefile
feeds, and the feed layout. She reviews a steady stream of contributions and
holds them to reproducible, hermetic builds and correct license metadata. She
works several release branches at once and reads a diff for upstream-cleanliness
before she forwards it.

## Scenarios

- A new UDPspeeder-simd release lands. Ingrid updates the feed Makefile version
  and source hash, builds the package against the current buildroot, and confirms
  it installs and runs on a test device.
- A contributor opens a change to the feed. Ingrid checks it applies cleanly and
  carries no automated co-author trailer (see
  [`call/0003`](../call/0003-no-claude-co-author-trailers-on-packages.md)) before
  she offers it to `openwrt/packages`.

## Priority

Primary persona for the packages lane. The feed exists to let her ship the
software to OpenWrt users, and her upstream-clean workflow shapes how commits are
made there.

*First-draft persona, built from the role and this project's domain. Refine by
discussion with the operator (see [applying-personas.md](applying-personas.md)).*
