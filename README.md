# agentic-UDPspeeder-simd

The governance shell for **UDPspeeder-simd**, a Forward Error Correction UDP tunnel
(C++, forked from UDPspeeder). This repository holds the *thought*: the plans,
decisions, personas, and the operating manual. The software itself, the *action*,
lives beneath it as a bare store with a worktree, kept separate and independently
versioned.

Read [`CLAUDE.md`](CLAUDE.md) first; it is the operating manual and works literally.
[`STRUCTURE.md`](STRUCTURE.md) is the one-page map. The process that built this
host lives in the [`host` repository](https://github.com/connollydavid/host).

## Layout

| Room | Holds |
|---|---|
| `cast/` | personas (the Who); examples pending replacement |
| `plan/` | the milestone index |
| `call/` | decisions, in MADR format |
| `software/` | the hosted software, materialized locally (gitignored) |
| `tools/` | the verification tools, referenced submodules |

The software is pinned in [`.host-software`](.host-software) and materialized with
`host-lifecycle software --materialize .` into `software/udpspeeder-simd/branch_libev/`.

## Tooling

`host-lifecycle` and `host-lint` drive the mechanical work. Build them from the
`tools/` submodules, then generate the skill symlinks and install the commit gate:

```
git submodule update --init --recursive
./link-skills.sh
host-lifecycle software --materialize .
host-lifecycle software --install-hooks .
```

## License

This governance shell is released into the public domain (Unlicense). The hosted
software, UDPspeeder-simd, carries its own MIT license in its worktree.
