ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:3.21
FROM $BUILD_FROM
RUN apk add --no-cache bluez dbus
COPY run.sh /run.sh
RUN chmod a+x /run.sh
CMD ["/run.sh"]
