#!/usr/bin/with-contenv bashio
# Talks to the HOST's bluetoothd over the system D-Bus (host_dbus) with host networking so the
# kernel Bluetooth sockets are reachable. Never aborts on a failed bluetoothctl call.
set +e
MAC=$(bashio::config 'mac')
SCAN=$(bashio::config 'scan_seconds')
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
bt() { timeout 25 bluetoothctl -- "$@" 2>&1; }
command_loop() {
  bashio::log.notice "Command channel: send bluetoothctl/pactl commands with the HA action hassio.addon_stdin (e.g. 'scan bredr', 'devices', 'info XX:..', 'connect XX:..', 'pactl list short sinks')."
  while IFS= read -r line; do
    line="${line#\"}"; line="${line%\"}"   # the Supervisor passes stdin JSON-quoted
    [ -z "${line}" ] && continue
    bashio::log.info "> ${line}"
    case "${line}" in
      pactl*) timeout 30 ${line} 2>&1 | sed 's/^/   /' ;;
      scan*) bluetoothctl --timeout 35 -- ${line} 2>&1 | grep -E "NEW|CHG.*Name|Failed" | sed 's/^/   /' ;;
      *)     timeout 40 bluetoothctl -- ${line} 2>&1 | sed 's/^/   /' ;;
    esac
    bashio::log.info "< done: ${line}"
  done
}
bashio::log.info "D-Bus socket present: $([ -S /run/dbus/system_bus_socket ] && echo yes || echo NO)"
bashio::log.info "Adapters: $(bt list | tr '\n' ' ')"
bashio::log.info "power on: $(bt power on | tail -1)"
bt agent NoInputNoOutput >/dev/null; bt default-agent >/dev/null
if [ -z "${MAC}" ]; then
  bashio::log.notice "No 'mac' configured. Put the speaker in pairing mode; scanning ${SCAN} s (LE + classic)..."
  bashio::log.info "adapter: $(bt show | grep -E 'Powered|Discovering|Pairable' | tr '
' ' ')"
  bluetoothctl --timeout "${SCAN}" -- scan on 2>&1 | grep -E "NEW" | sed 's/^/   LE+classic: /'
  bashio::log.notice "classic (BR/EDR) inquiry for ${SCAN} s..."
  bluetoothctl --timeout "${SCAN}" -- scan bredr 2>&1 | grep -E "NEW|Failed|not" | sed 's/^/   classic: /'
  bashio::log.notice "Known/seen devices (copy the speaker's MAC into the add-on options, then restart):"
  bt devices | sed 's/^/   /'
  command_loop
  exit 0
fi
bashio::log.info "Target speaker: ${MAC}"
(
was_connected=""
while true; do
  info=$(bt info "${MAC}")
  if echo "${info}" | grep -q "Connected: yes"; then
    [ "${was_connected}" != "yes" ] && bashio::log.info "Speaker connected"
    was_connected=yes; sleep 20; continue
  fi
  [ "${was_connected}" = "yes" ] && bashio::log.warning "Speaker disconnected (switched off, out of range or auto-off); will keep trying to reconnect every 30 s"
  was_connected=no
  if echo "${info}" | grep -q "Paired: no"; then
    # bond lost on our side: only then pair again (needs the speaker in pairing mode)
    bashio::log.info "Bond missing: scanning ${SCAN} s, then pairing (speaker must be in pairing mode)"
    bluetoothctl --timeout "${SCAN}" -- scan bredr >/dev/null 2>&1
    bashio::log.info "pair: $(bt pair "${MAC}" | tail -1)"
    bt trust "${MAC}" >/dev/null
  fi
  result=$(bt connect "${MAC}" | tail -1)
  case "${result}" in
    *successful*) bashio::log.info "connect: ${result}" ;;
    *) sleep 30 ;;   # unreachable: quiet retry
  esac
done
) &
command_loop
wait
