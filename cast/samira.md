# Samira (security engineer)

Samira reviews UDPspeeder-simd as a network service that parses untrusted input.
The tunnel reads UDP packets from the open network and decodes them in C++, so
she treats every packet as potentially hostile.

## Goals

- Assure that malformed or crafted packets cannot corrupt memory or crash the
  tunnel, since the receive path handles attacker-controlled bytes.
- Understand the threat model of the obfuscation and password features, and
  confirm the shipped defaults are safe.
- Confirm the Reed-Solomon decoding path enforces its buffer bounds under
  adversarial input, with no out-of-bounds access.
- Tie each security claim to a rung of the verification ladder, so a claim is
  backed by a check rather than an assertion.

## Personalization and technical ability

A senior security engineer who reads C++ fluently, threat-models network
services, and runs fuzzers and static analysis. She distrusts undocumented
invariants and asks for the check that proves one. She prefers a bound proven for
all inputs over a bound sampled by tests.

## Scenarios

- Samira fuzzes the packet-receive path with malformed frames, reviews how the
  decoding bounds are enforced, and records the invariants she expects as spec
  obligations for the requirements lane.
- Reviewing a change to the FEC buffer handling, she asks for a CBMC proof on the
  C path that the bound holds for all inputs before the change ships.

## Priority

Secondary persona, cross-cutting both the tunnel and the feed. She is a served
reviewer whose obligations feed the spec lanes, so her concerns turn into
behavioural specs, timing checks, and code-conformance proofs rather than a
separate interface.

*First-draft persona, built from the role and this project's domain. Refine by
discussion with the operator (see [applying-personas.md](applying-personas.md)).*
