# Govern UDPspeeder-simd under the agentic-host methodology

- Status: accepted
- Scope: udpspeeder-simd
- Date: 2026-07-02

## Context and Problem Statement

UDPspeeder-simd is a pre-existing C++ project (a Forward Error Correction UDP
tunnel, forked from UDPspeeder) developed on a bare commit history. The reasoning
behind its choices lives only in commit messages and is lost across sessions, with
no durable record of decisions or specs.

## Decision

Govern development of UDPspeeder-simd under the agentic-host methodology, adopted
from the `host-template` repository at revision `565410a` (recorded in `.host`).

- The host repository (`agentic-UDPspeeder-simd`) holds the thought: plans
  (`plan/`), decisions (`call/`), personas (`cast/`), and the operating manual
  (`CLAUDE.md`).
- The software itself stays separate as the Where room, a bare store with a
  worktree under `software/udpspeeder-simd/branch_libev/`, recorded in
  `.host-software` and pinned to its `branch_libev` head. The host never adopts a
  software repository in place.
- The methodology rules live in the spine (`CLAUDE.md` plus `STRUCTURE.md`),
  inherited copy-at-version from the template; they are not re-litigated here. A
  later change to them arrives by `host-lifecycle upgrade` against the template's
  `UPGRADING.md` ledger.

## Consequences

- Good: decisions, plans, and specs gain a durable, citable home; the software pin
  is a real audit anchor; tooling upgrades are mechanical and token-free.
- Neutral: this is one of two numbered registers (milestones and decisions), kept
  apart by home. The software keeps its own MIT license; this governance shell is
  released into the public domain (Unlicense).
