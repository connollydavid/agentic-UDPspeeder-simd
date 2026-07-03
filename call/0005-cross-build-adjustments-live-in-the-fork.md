# Cross-build adjustments for udpspeeder-simd live in the fork

- Status: accepted
- Scope: udpspeeder-simd
- Date: 2026-07-03

## Context and Problem Statement

The OpenWrt package builds udpspeeder-simd from the fork's source. Any change the
cross build needs (for example gating the io_uring path on a toolchain that lacks
the syscall numbers, or a clean cross entry point) can live either in the fork's
own makefile or as patches applied from the feed's package Makefile. The existing
`udpspeeder` package patches upstream's makefile from the feed with `sed`.

## Decision

Make the build adjustments in the fork's makefile, then update the
`.host-software` pin, rather than carry feed-side patches. connollydavid owns the
fork, so a fix there is upstreamable and keeps the feed Makefile thin. The fork's
`cross` target already links dynamically, so the adjustments are expected to be
small.

## Consequences

- Good: the feed Makefile stays close to a stock build, which reviews more easily.
- Good: the fix benefits anyone who builds the fork, not only the OpenWrt package.
- Neutral: each fork build change is a fork commit (with the normal sign-off and
  co-author trailer) followed by a re-pin, per the software discipline.
