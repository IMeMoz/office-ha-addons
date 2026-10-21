#!/usr/bin/with-contenv bashio
# Talks to the HOST's bluetoothd over the system D-Bus (host_dbus: true).
MAC=$(bashio::config 'mac')
SCAN=$(bashio::config 'scan_seconds')
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
bt() { bluetoothctl -- "$@" 2>&1; }
bashio::log.info "Bluetooth adapter: $(bt list | head -1)"
bt power on >/dev/null
bt agent NoInputNoOutput >/dev/null; bt default-agent >/dev/null
if [ -z "${MAC}" ]; then
  bashio::log.notice "No 'mac' configured. Put the speaker in pairing mode; scanning ${SCAN} s..."
  timeout "${SCAN}" bluetoothctl -- scan on >/dev/null 2>&1 || true
  bashio::log.notice "Devices seen (copy the speaker's MAC into the add-on options, then restart):"
  bt devices | sed 's/^/   /'
  exit 0
fi
bashio::log.info "Target speaker: ${MAC}"
while true; do
  if bt info "${MAC}" | grep -q "Connected: yes"; then
    sleep 20; continue
  fi
  if ! bt info "${MAC}" | grep -q "Paired: yes"; then
    bashio::log.info "Not paired yet: scanning ${SCAN} s, then pairing (speaker must be in pairing mode)"
    timeout "${SCAN}" bluetoothctl -- scan on >/dev/null 2>&1 || true
    bt pair "${MAC}" | tail -2
  fi
  bt trust "${MAC}" >/dev/null
  bashio::log.info "Connecting ${MAC}..."
  bt connect "${MAC}" | tail -1
  sleep 15
done
