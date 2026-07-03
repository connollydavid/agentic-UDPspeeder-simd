# Samira (security engineer)

Samira reviews UDPspeeder-simd as a network service that parses untrusted input.
The tunnel reads UDP packets from the open network and decodes them in C++, so she
treats every packet as potentially hostile.

## Goals

- Assure that malformed or crafted packets cannot corrupt memory or crash the
  tunnel, since the receive path in C++ handles attacker-controlled bytes.
- Confirm the Reed-Solomon decode path enforces its buffer bounds under adversarial
  input, and that a crafted stream cannot exhaust the decode buffer (`--decode-buf`)
  or turn the server into a reflection or amplification vector.
- Set expectations for the `-k` key correctly. It applies a simple XOR, which gives
  no cryptographic confidentiality, so she checks that the defaults and the
  documentation state the safe pattern plainly: run UDPspeeder under a real VPN such
  as OpenVPN when the traffic needs protecting.
- Tie each security claim to a rung of the verification ladder, so a claim rests on
  a check rather than an assertion.

## Personalization and technical ability

A senior security engineer who reads C++ fluently, threat-models network services,
and runs fuzzers and static analysis. She distrusts undocumented invariants and
asks for the check that establishes one. She prefers a bound proven for all inputs
over a bound sampled by tests.

## Scenarios

- Samira fuzzes the packet-receive path with malformed frames under address and
  undefined-behaviour sanitizers, reviews how the decode bounds are enforced, and
  records the invariants she expects as spec obligations for the requirements lane.
- Reviewing a change to the FEC buffer handling, she asks for the decode bound to be
  proven for all inputs where the C++ code admits a bounded model check, and
  exhaustively fuzzed under sanitizers where it does not, before the change ships.

## Priority

Secondary persona, cross-cutting the tunnel and the feed. She is a served reviewer
whose obligations feed the spec lanes, so her concerns become behavioural specs,
timing checks, and code-conformance proofs rather than a separate interface. On the
feed she also watches the supply chain, so a Makefile fetches only pinned,
hash-verified sources.

*Grounded in the role and the UDPspeeder-simd source. Refine further by discussion
with the operator (see [applying-personas.md](applying-personas.md)).*
