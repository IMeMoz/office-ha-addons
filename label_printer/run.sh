#!/usr/bin/with-contenv bashio
# Forward raw print jobs from TCP 9100 straight to the USB printer, one job at a time.
PRINTER=/dev/usb/lp0
bashio::log.info "Label printer bridge: TCP 9100 -> ${PRINTER}"
while true; do
  if [ ! -e "${PRINTER}" ]; then
    bashio::log.warning "${PRINTER} not present (printer off or unplugged); retrying in 10 s"
    sleep 10; continue
  fi
  socat -d -d TCP-LISTEN:9100,reuseaddr,fork OPEN:"${PRINTER}",wronly || true
  sleep 2
done
