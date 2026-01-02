#!/usr/bin/with-contenv bashio

# Our parameters
CONFIG_DIR=/config
OVPN=$CONFIG_DIR/client.ovpn
TEXT=$CONFIG_DIR/client.text

TUN=/dev/net/tun

BIN=/usr/sbin/openvpn
PID=/openvpn.pid
DEF_PARAMS="--writepid $PID --config $OVPN"

# Log with date and time
__BASHIO_LOG_TIMESTAMP="%Y-%m-%d %H:%M:%S"

rm -f $PID

# Run the web server
bashio::log.info Starting web server
lighttpd -D -f /lighttpd.conf &

# Do we have a tunnel device?
if [ -e $TUN ]; then
    bashio::log.info Tunnel device found
else
    bashio::log.warning Tunnel device missing
    # mknod $TUN c 10 200
fi

# Are the configuration files available?
bashio::log.info Looking for configuration
found=0
while true; do
    if [ -r $OVPN ]; then
        bashio::log.info "Found configuration file(s):"
        found=1
        ls -l $OVPN
        PARAMS="$DEF_PARAMS"
        if [ -r $TEXT ]; then
            ls -l $TEXT
            PARAMS="$PARAMS --auth-user-pass $TEXT"
        fi
    fi
    if [ $found -eq 1 ]; then
        break
    fi
    bashio::log.info Waiting for configuration
    sleep 60
done

# Run OpenVPN
while true; do
    bashio::log.info Starting OpenVPN
    PARAMS="$DEF_PARAMS"
    if [ -r $TEXT ]; then
        PARAMS="$PARAMS --auth-user-pass $TEXT"
    fi
    bashio::log.info $BIN $PARAMS
    $BIN $PARAMS || true
    rm -f $PID
    bashio::log.info Waiting for restart
    sleep 60
done
