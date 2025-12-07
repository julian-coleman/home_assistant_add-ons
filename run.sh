#!/usr/bin/with-contenv bashio

# Our parameters
CONFIG_DIR=/config
OVPN=$CONFIG_DIR/client.ovpn
TEXT=$CONFIG_DIR/client.text

TUN=/dev/net/tun

BIN=/usr/sbin/openvpn
PID=/openvpn.pid
PARAMS="--writepid $PID --config $OVPN"

date

# Run the web server
echo Starting web server
lighttpd -f /lighttpd.conf

# Do we have a tunnel device?
if [ -e /dev/net/tun ]; then
    echo Tunnel device found
else
    echo Creating tunnel device
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
fi

# Are the configuration files available?
echo Looking for configuration
while true; do
    if [ -r $OVPN ]; then
        echo "Found configuration file(s):"
        ls -l $OVPN
        if [ -r $TEXT ]; then
            ls -l $TEXT
            PARAMS="$PARAMS --auth-user-pass $TEXT"
        fi
    fi
    break
    echo Waiting for configuration file
    sleep 300
    date
done

# Run OpenVPN
while true; do
    echo Starting OpenVPN
    echo $BIN $PARAMS
    $BIN $PARAMS || true
    sleep 60
done
