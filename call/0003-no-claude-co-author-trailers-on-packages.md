# No Claude co-author trailers on packages commits

- Status: accepted
- Scope: packages
- Date: 2026-07-03

## Context and Problem Statement

The `packages` component is a fork of the OpenWrt packages feed
(`openwrt/packages`, GPL-2.0). Work done here may be offered back to that
upstream, whose commit history carries no AI-assistant co-author trailers and
whose authorship attribution stays clean for a community feed. This host's
default agent behaviour appends a `Co-Authored-By: Claude ...` trailer to commit
messages. That trailer is unwanted on any commit in the packages worktree.

## Decision

Every commit created in the packages worktree (`software/packages/<branch>/`)
omits the `Co-Authored-By: Claude ...` trailer. An agent committing under
`software/packages/` suppresses the trailer its default behaviour would add. The
prohibition is scoped to the packages component; the operator confirmed the scope
is packages only, so commits in this host repository keep the trailer as before.

## Consequences

- Good: packages commits stay upstream-clean, so a change offered to
  `openwrt/packages` needs no trailer scrubbing.
- Neutral: the rule is a commit-message convention rather than a hook the host
  enforces, because the packages worktree is a separate repository with its own
  hooks. An agent honours it by reading this decision and the CLAUDE.md
  project-specifics note that points here.
- Follow-up: if upstream provenance later needs a DCO sign-off or another trailer
  policy, record it as a sibling decision under the same scope.
