#!/usr/bin/with-contenv bash
# ==============================================================================
#
# Transmission
#
# The bittorent client for Hass.io.
#
# ==============================================================================
set -o errexit  # Exit script when a command exits with non-zero status
set -o errtrace # Exit on error inside any functions or sub-shells
set -o nounset  # Exit script on use of an undefined variable
set -o pipefail # Return exit status of the last command in the pipe that failed

# shellcheck disable=SC1091
source /usr/lib/hassio-addons/base.sh

# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
    if hass.config.true 'transmission_rss_enabled'; then
      if [ -e '/config/transmission-rss.conf' ]; then
        transmission-rss -c /config/transmission-rss.conf
      else
        echo "Transmission Rss file not file"
        touch /config/transmission-rss.conf
        exit(1)
      fi
    fi

    if hass.config.true 'openvpn_enabled'; then
        exec /usr/sbin/openvpn --config /etc/openvpn/config.ovpn --script-security 2 --up /etc/openvpn/up.sh --down /etc/openvpn/down.sh
    else
      if hass.config.true 'transmission_ssl'; then
        exec  /usr/sbin/nginx -g 'pid /tmp/nginx.pid; daemon off;' &
      fi
        exec /usr/bin/transmission-daemon --foreground --config-dir /data/transmission
    fi
}
main "$@"
