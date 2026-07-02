# host-lint is a consumed tool, not reproduced by this host

- Status: accepted
- Scope: host-lint
- Date: 2026-07-02

## Context and Problem Statement

`host-lint` is registered in `.host-software` so `host-lifecycle software
--install-hooks` can install its `pre-commit` hook and built binary as this host's
commit gate. The software check requires a component that records an `artifact`
hash to also record a `toolchain` pin, so the artifact is reproducibly verifiable.
This host does not build host-lint reproducibly. It pins an upstream release, then
builds the binary locally so the commit gate can install it. No reproducible build
of that binary is claimed here.

## Decision

Carry `repro-exempt = call/0002` on the `host-lint` component and record no `build`
or `toolchain` recipe. The pinned source SHA (in `.host-software`) plus the recorded
artifact hash (a local-build anchor that attests the installed binary came from that
source) are the interim provenance. host-lint's own reproducibility is the upstream
maintainer's concern, attested by its released tags.

## Consequences

- Good: the commit gate installs and runs; the cheap `software --check` passes
  without this host claiming a reproducible build it does not perform.
- Neutral: `host-lifecycle software --verify-build` reports host-lint as exempt and
  skips the rebuild comparison. Retire this exemption only if this host begins to
  build host-lint itself, which is not the case for a consumer.
