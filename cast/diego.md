# Diego (router administrator)

Diego runs the gateway for a remote site on a high-latency, lossy WAN link. He
deploys UDPspeeder-simd on that gateway to make the link usable for real-time
traffic.

## Goals

- Keep a lossy link usable for voice, video, and remote access by putting the
  tunnel in front of the traffic that suffers from packet loss.
- Configure and update the tunnel through OpenWrt's normal tools, without editing
  or building C++.
- Run the tunnel inside the CPU and memory limits of modest router hardware.
- See whether the tunnel is healthy and how much redundancy it is adding, so he
  can tune the trade-off between overhead and recovery.

## Personalization and technical ability

A competent network administrator for a small operator or a remote installation.
He is comfortable on the OpenWrt command line and with UCI configuration, reads
logs, and scripts routine tasks. He is not a C++ developer, and he treats the
tunnel as an appliance that has to stay up while he is not watching it.

## Scenarios

- Diego installs the package on a satellite-backed site, sets the tunnel
  endpoints and the redundancy level, and confirms that call quality holds up
  under measurable packet loss.
- A firmware upgrade replaces the device configuration. Diego re-applies his
  tunnel settings from a saved UCI snapshot and verifies the link recovers
  without hand-tuning.

## Priority

Primary end-user persona for UDPspeeder-simd. The tunnel exists to serve his
link, so his constraints (appliance-grade stability, modest hardware, no source
edits) drive the software's defaults and ergonomics.

*First-draft persona, built from the role and this project's domain. Refine by
discussion with the operator (see [applying-personas.md](applying-personas.md)).*
