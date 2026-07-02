# Pin the verification tools to current releases, not the template gitlinks

- Status: accepted
- Scope: udpspeeder-simd
- Date: 2026-07-02

## Context and Problem Statement

The adopt guidance says to wire each `tools/` submodule "to the commit the
template references at this revision." The template at `565410a` records these
gitlink SHAs in its `.gitmodules`: host-lint `2ef5399` (v0.2.0), host-lifecycle
`2a24deb` (v0.15.1), allium `82da292`, specula `38e9d6e`. Those gitlinks are stale:
host-lint v0.2.0 predates the `--docs` engine, and host-lifecycle v0.15.1 predates
`book`, `prose`, `software --install-hooks`, and `reconcile`, which the
methodology's own workflows call. The template's `prose.yml` pins host-lifecycle at
`46d481cd` (a far newer revision than its gitlink), confirming the gitlinks lag the
working set.

## Decision

Pin the `tools/` submodules to current, working releases instead of the stale
gitlinks, so the methodology's CI lanes and the commit gate actually run:

- `tools/host-lint` at `78804cd` (v0.12.1)
- `tools/host-lifecycle` at `486add7` (v0.35.1)
- `tools/allium` at `493a2de` (v3.6.0)
- `tools/specula` at `fa12367`

## Consequences

- Good: the commit gate (`host-lint --stdin`), the prose lane (`host-lifecycle
  prose`), the site publisher (`host-lifecycle book`), and the embed hook installer
  all run against tool versions that actually implement them.
- Neutral: the submodules drift ahead of the template's recorded gitlinks. A later
  template bump that refreshes its gitlinks reconciles this; until then the pins
  live here in `.gitmodules`, the source of truth for this host.
