# Add an OpenWrt package for udpspeeder-simd

- Status: planned
- Persona: Ingrid (OpenWrt feed maintainer)
- Serves: https://github.com/openwrt/packages/issues/28562
- Scope: the `packages` and `udpspeeder-simd` components

## Why

The issue at https://github.com/openwrt/packages/issues/28562 asks for the
performance-optimised UDPspeeder on low-end devices; the reporter's target is
`ath79/generic`, a MIPS 24Kc core. UDPspeeder-simd is that optimised fork. Rather
than repoint the existing `net/udpspeeder` package at a fork, this milestone adds a
separate `net/udpspeeder-simd` package that coexists with `udpspeeder` and ships a
self-contained binary.

On `ath79` the gain comes from the portable word-width XOR and the portable
Reed-Solomon speedups, not from SIMD. The source carries no MIPS SIMD path, and
none is worthwhile on the 24Kc core (MSA is absent on that core, and its optional
DSP ASE targets fixed-point math rather than vector XOR).

## Design (proposed, pending operator ratification and call/ records)

- Coexistence: a distinct package `udpspeeder-simd` with distinct paths
  (`/usr/bin/udpspeeder-simd`, `/etc/config/udpspeeder-simd`,
  `/etc/init.d/udpspeeder-simd`), no file clash with `udpspeeder`, no `CONFLICTS`.
- Static: link the binary so it carries no `libstdcpp`/`librt`/`libatomic` runtime
  dependency. Fallback if a fully static C++ build draws reviewer objection: static
  `libstdc++` only.
- Build adjustments live in the fork's makefile, after which the `.host-software`
  pin is updated, rather than patched only in the feed.
- Maintainer: David Connolly <david@connol.ly>.
- The first PR targets OpenWrt master only; backports to the supported release
  branches follow.

## Build sequence

### Make the fork build static across architectures {#fork-build}

- verify: the OpenWrt SDK cross-compiles a static binary for a mips_24kc target

### Author the udpspeeder-simd feed package {#feed-package}

- depends: #fork-build
- verify: the OpenWrt SDK builds the udpspeeder-simd package for ath79/generic

### Confirm polite interop with the udpspeeder package {#interop}

- depends: #feed-package
- verify: the udpspeeder-simd file paths are disjoint from udpspeeder, no clash

### Open the pull request to OpenWrt master {#pr}

- depends: #interop
- verify: attested operator
