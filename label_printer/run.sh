#!/usr/bin/with-contenv bashio
# Forward raw print jobs from TCP 9100 straight to the USB printer, one job at a time.
# The device is mapped at container start; if the printer is unplugged or power-cycled the
# mapping goes stale, so we exit and let the Supervisor watchdog restart us with a fresh one.
set +e
PRINTER=/dev/usb/lp0
bashio::log.info "Label printer bridge: TCP 9100 -> ${PRINTER}"
fails=0
while true; do
  if [ ! -c "${PRINTER}" ] || ! ( : < "${PRINTER}" ) 2>/dev/null; then
    fails=$((fails + 1))
    bashio::log.warning "${PRINTER} not usable (printer off or unplugged?), attempt ${fails}/6"
    [ "${fails}" -ge 6 ] && { bashio::log.error "Giving up; exiting so the watchdog restarts the add-on with a fresh device mapping"; exit 1; }
    sleep 10; continue
  fi
  fails=0
  bashio::log.info "Printer present, bridging TCP 9100 -> ${PRINTER}"
  socat -d TCP-LISTEN:9100,reuseaddr,fork OPEN:"${PRINTER}",wronly
  bashio::log.warning "socat ended (exit $?); re-checking the printer in 2 s"
  sleep 2
done
