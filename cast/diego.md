# Diego (router administrator)

Diego runs the gateway for a remote site on a high-latency, lossy WAN link. He
puts UDPspeeder-simd on that gateway, with a matching server endpoint he controls
on the far side, to make the link usable for real-time traffic.

## Goals

- Keep a lossy link usable for voice, video, and remote access by tunnelling the
  affected traffic through the client-and-server pair.
- Tune the redundancy ratio (the `-f x:y` setting) so he recovers lost packets
  without spending more upstream bandwidth than the link can spare.
- Manage the tunnel through OpenWrt's service and configuration tools, without
  editing or building C++.
- Run the tunnel inside the CPU and memory limits of modest router hardware, where
  a feature such as io_uring may be missing from the kernel.
- See whether the tunnel is healthy and how much loss it is recovering, so he can
  adjust as the link changes.

## Personalization and technical ability

A competent network administrator for a small operator or a remote installation.
He is comfortable on the OpenWrt command line and with UCI configuration, reads
logs, and scripts routine tasks. He is not a C++ developer, and he treats the
tunnel as an appliance that has to stay up while he is not watching it.

## Scenarios

- Diego installs the package on a satellite-backed site, points the client at his
  server endpoint, sets the redundancy ratio, and confirms that call quality holds
  up under measurable packet loss.
- A firmware upgrade replaces the device configuration. Diego re-applies his tunnel
  settings from a saved snapshot and verifies the link recovers without hand-tuning.

## Priority

Primary end-user persona for UDPspeeder-simd, and the anchor for prioritising the
tunnel's own stories. The tunnel exists to serve his link, so his constraints
(appliance-grade stability on modest hardware, with no source edits) drive the
software's defaults and ergonomics. He depends on Ingrid's package for the service
integration he configures.

*Grounded in the role and the UDPspeeder-simd source. Refine further by discussion
with the operator (see [applying-personas.md](applying-personas.md)).*
