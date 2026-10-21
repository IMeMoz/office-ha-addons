# Label printer (raw network port) - local Home Assistant add-on

Bridges the USB label printer (/dev/usb/lp0 on the Pi) to TCP port 9100, the "raw" / JetDirect
protocol every OS can print to. The vendor's printer driver stays on the client PC; the Pi only
passes the bytes through, so it works with any printer language (TSPL, ESC/POS, ZPL).

Install: copy this folder to /addons/label_printer on the Pi, then in HA go to
Settings > Add-ons > Add-on store > (three dots) > Check for updates, open "Local add-ons",
install "Label printer (raw network port)" and start it.

Client setup (Windows): Settings > Bluetooth & devices > Printers & scanners > Add device >
Add manually > "Add a printer using an IP address or hostname" > Device type: TCP/IP Device,
address 192.168.10.99, untick "Query the printer", Custom port settings: Raw, port 9100,
then pick the label printer driver you already use.
