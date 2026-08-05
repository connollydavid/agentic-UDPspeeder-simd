# udpspeeder-simd release binaries are not yet reproducible

- Status: accepted
- Scope: udpspeeder-simd
- Date: 2026-08-05

## Context and Problem Statement

On 2026-08-03 this project began publishing binaries. The v1.0.1 and v1.0.2
releases each carry five static executables, one per architecture, and a
`tooling-sde-10.13.1` release mirrors a third-party emulator.

The methodology is explicit that this brings an obligation: a component shipping
static or self-contained release binaries must be able to reproduce them offline
from pinned inputs, and must record which line ships (`deploy`) together with the
artifact's expected hash (`artifact = <path> <sha256>`). The `udpspeeder-simd`
stanza in `.host-software` records none of that. It carries a source `pin` and
nothing else, so the gate has no build to check and no hash to compare.

We cannot honestly record an `artifact` today. The binaries were built by GitHub
Actions on `ubuntu-latest` using whatever `g++` that image carried on the day,
which is not a pinned toolchain, and nothing in the build fixes timestamps, build
paths or `-frecord-gcc-switches` output. A second run on a later image would very
likely differ. Recording a hash for a build that cannot be reproduced would state
a guarantee we have not established, which is the fault this project spent the
week removing from its verification lanes rather than one to introduce here.

## Considered Options

- Record `build`, `toolchain`, `artifact` and `deploy` now, and accept that
  `--verify-build` fails until the build is made deterministic.
- Record a `repro-waiver` citing this decision, and state the route out.
- Stop publishing binaries until the build is reproducible.

## Decision

Record `repro-waiver = call/0006` on the `udpspeeder-simd` stanza.

The escape clause fits this component exactly. `udpspeeder-simd` is pre-existing
software brought under the methodology rather than initiated by it, so the
reproducibility obligation is one it converges on rather than one it was born
with. The waiver is the honest record of that, and it keeps `software --check`
able to distinguish "no claim made" from "claim made and unmet".

Publishing continues. The interim provenance is not nothing:

- Every release binary is built by a workflow run in a public repository, from a
  tagged commit, and the run that produced it is linkable.
- The four cross toolchains are now hash-pinned in `bench/arch-map.tsv`, and the
  download step fails on a mismatch, so the cross binaries are built by a
  compiler we have named rather than whatever a URL returned.
- The mirrored emulator is pinned by sha256 in `bench/sde.lock` and carries a
  detached Intel signature, verified before the hash was recorded.

## Consequences

The gate stops being silent about this component. `software --check` requires the
citation to resolve, and `--verify-build` warns and skips rather than reporting a
reproducibility it never tested.

What remains owed, and what retires this waiver: a pinned toolchain for the
native x86_64 build, so every line has a named compiler rather than the runner's
default; a deterministic build, which for this makefile means at least
`SOURCE_DATE_EPOCH`, `-ffile-prefix-map` and a fixed link order; and then
`build`, `toolchain`, `artifact` and `deploy` recorded per line, with
`--verify-build` green. At that point this decision is superseded rather than
deleted, and the waiver comes off the stanza.

The `tooling-sde-10.13.1` release is outside all of this. It republishes Intel's
tarball byte for byte and builds nothing, so there is no artifact of ours to
reproduce; its provenance is the recorded sha256 and Intel's own signature.
