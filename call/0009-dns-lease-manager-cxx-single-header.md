# The DNS lease manager ships as a C++-compatible single header

- Status: accepted
- Scope: udpspeeder-simd
- Date: 2026-08-10

## Context and Problem Statement

The DNS lease manager for `plan/0001` was specified as a strict C11 single-header
library: allocation-free, `mem*`-only string handling, no OS resolver APIs, no
threads, no recursion, no floating point, no unaligned access, no global mutable
state, no `stdio` in the protocol path, all functions `static inline`.

The fork builds C++-only: the flat makefile compiles every translation unit with
`g++ -std=c++11`, there is no C compiler in the build, and adding one (a `.c`
translation unit, a C compiler target, cross-compiler coverage for every OpenWrt
target) would be a build-system change purely to satisfy a language dialect. A C11
header's negative constraints are not C-specific; they are properties of how the
library must behave, and C++ can hold them all.

## Decision

Write the DNS lease manager as a single header compiled by the existing C++ build,
preserving every negative constraint from the C11 specification unchanged: no
dynamic allocation, `memcpy`/`memmove`/`memcmp`/`memset` only, no `getaddrinfo` or
any OS resolver API, no threads/mutexes/atomics/signals, no recursion or
`longjmp`/`setjmp`, no floating-point math, no unaligned memory access or struct
casting for network parsing (manual byte shifting), no global mutable state (all
state in the caller-provided `dns_lease_ctx`), and no `stdio` in the protocol path
(resolv.conf discovery uses `open`/`read`/`close`; logging is a caller-supplied
callback). All functions remain `static inline`.

The only change is the dialect: the header is valid C++11 so it compiles under the
fork's existing `-std=c++11` with zero build-system change.

## Consequences

- Good: the fork's build and its cross-compiler matrix are untouched; the header
  compiles on every target the fork already builds.
- Good: the constraints the spec was really about (no allocation, no OS resolver,
  parser bounds safety, no ambient state) are preserved and enforced by the same
  review and test gate a C11 header would face.
- Neutral: the header is not valid C compilation, so it cannot be reused by a C
  consumer without a translation; the project is C++-only, so no such consumer
  exists today.
- Follow-up: if upstream or a future consumer needs a C11 build, the header is
  already written to C11-compatible idioms where C++ and C differ, so the remaining
  work is a dialect pass, not a rewrite.