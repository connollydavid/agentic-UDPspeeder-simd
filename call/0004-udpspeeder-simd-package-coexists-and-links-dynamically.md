# The udpspeeder-simd package coexists with udpspeeder and links dynamically

- Status: accepted
- Scope: packages
- Date: 2026-07-03

## Context and Problem Statement

The issue at https://github.com/openwrt/packages/issues/28562 asks for the
performance-optimised UDPspeeder on low-end OpenWrt devices. The feed already
carries `net/udpspeeder` (the upstream UDPspeeder). A udpspeeder-simd package has
to avoid clashing with that package, and it has to choose how the binary links.
The operator first asked for a static build.

## Decision

Ship a distinct package `udpspeeder-simd` with distinct paths
(`/usr/bin/udpspeeder-simd`, `/etc/config/udpspeeder-simd`,
`/etc/init.d/udpspeeder-simd`), so it installs alongside `udpspeeder` with no file
clash and no `CONFLICTS`.

Link the binary dynamically, with `DEPENDS` on the shared libraries it needs (the
`udpspeeder` package depends on `libstdcpp`, `librt`, and `libatomic`). Do not
build statically. A static C++ binary is larger on flash, which works against the
low-end devices the issue targets, and static linking runs against OpenWrt's
shared-library model. The operator settled this: no static builds for OpenWrt.

## Consequences

- Good: the package matches OpenWrt's conventions and the sibling `udpspeeder`
  package, holds the flash footprint down, and reviews cleanly.
- Good: both packages install together, so a user can compare them.
- Neutral: the exact `DEPENDS` set is confirmed when the package first builds
  against the SDK.
