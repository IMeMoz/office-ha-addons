# Bluetooth speaker keeper - local Home Assistant add-on

Home Assistant OS's audio service (PulseAudio) is built with Bluetooth support, but nothing in
HA OS pairs or connects a speaker. This add-on does that through the host's BlueZ over D-Bus and
keeps reconnecting when the speaker drops. Once connected, the speaker shows up as an audio
output that add-ons such as VLC Telnet can be pointed at (add-on page > Audio).

1. Install from Local add-ons, leave 'mac' empty, start it, put the speaker in pairing mode:
   the log lists the devices found.
2. Put the speaker's MAC into the options, restart the add-on. It pairs, trusts and connects.
3. Check Settings > System > Audio (or the Audio tab of the VLC Telnet add-on) for the new output.
