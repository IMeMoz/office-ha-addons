# Bluetooth speaker keeper - local Home Assistant add-on

Home Assistant OS's audio service (PulseAudio) is built with Bluetooth support, but nothing in
HA OS pairs or connects a speaker. This add-on does that through the host's BlueZ over D-Bus and
keeps reconnecting when the speaker drops. Once connected, the speaker shows up as an audio
output that add-ons such as VLC Telnet can be pointed at (add-on page > Audio).

1. Install from Local add-ons, leave 'mac' empty, start it, put the speaker in pairing mode:
   the log lists the devices found.
2. Put the speaker's MAC into the options, restart the add-on. It pairs, trusts and connects.
3. Check Settings > System > Audio (or the Audio tab of the VLC Telnet add-on) for the new output.

## Volume ramp for the alarm

Two extra stdin commands drive the speaker's hardware (AVRCP) volume, which is the real loudness ceiling:

- `ramp 5 10` remembers the current sink volume, then raises it to 100% in 10 equal-dB steps over 5 s.
- `restore` puts the remembered volume back (no-op if nothing was saved).

Used by the office alarm: the entry track swells the alarm in over 5 s while the speaker is ramped to maximum, and the volume is restored on disarm.

## Baseline volume

`volume_percent` (default 50) is the speaker hardware volume the add-on applies every time the speaker connects, because the speaker reports its own level on reconnect and would otherwise silently change how loud Home Assistant sounds. `baseline` on stdin re-applies it on demand.
