#!/bin/sh

IPC=$(curl -4 -s icanhazip.com | cut -d"." -f3)
IPD=$(curl -4 -s icanhazip.com | cut -d"." -f4)

if [ "$IPC" = "4" ]; then
    IPV6_ADDRESS="2403:6a40:0:40::$IPD:0000"
    PREFIX_LENGTH="64"
    INTERFACE="ens160"
    GATEWAY="2403:6a40:0:40::1"
elif [ "$IPC" = "5" ]; then
    IPV6_ADDRESS="2403:6a40:0:41::$IPD:0000"
    PREFIX_LENGTH="64"
    INTERFACE="ens160"
    GATEWAY="2403:6a40:0:41::1"
elif [ "$IPC" = "244" ]; then
    IPV6_ADDRESS="2403:6a40:2000:244::$IPD:0000"
    PREFIX_LENGTH="64"
    INTERFACE="ens160"
    GATEWAY="2403:6a40:2000:244::1"
else
    IPV6_ADDRESS="2403:6a40:0:$IPC::$IPD:0000"
    PREFIX_LENGTH="64"
    INTERFACE="ens160"
    GATEWAY="2403:6a40:0:$IPC::1"
fi

# Add the IPv6 address to the interface
ip -6 addr add "$IPV6_ADDRESS/$PREFIX_LENGTH" dev "$INTERFACE"

# Set the gateway
ip -6 route add default via "$GATEWAY" dev "$INTERFACE"

# Enable the interface
ip link set dev "$INTERFACE" up
