#!/bin/bash

LAN_IF="enp3s0"
WIFI_IF="wlp0s20f3"
ICON=""     # You want to use only this icon
DEFAULT_OUTPUT="$ICON 0KB/s"

get_total_speed() {
  local iface=$1

  RX1=$(cat /sys/class/net/$iface/statistics/rx_bytes)
  TX1=$(cat /sys/class/net/$iface/statistics/tx_bytes)
  sleep 1
  RX2=$(cat /sys/class/net/$iface/statistics/rx_bytes)
  TX2=$(cat /sys/class/net/$iface/statistics/tx_bytes)

  RX_KB=$(( (RX2 - RX1) / 1024 ))
  TX_KB=$(( (TX2 - TX1) / 1024 ))
  TOTAL=$(( RX_KB + TX_KB ))

  echo "$TOTAL"
}

# First try LAN
if [ -d "/sys/class/net/$LAN_IF" ] && ip link show "$LAN_IF" | grep -q "state UP"; then
  SPEED=$(get_total_speed "$LAN_IF")
  if [ "$SPEED" -gt 0 ]; then
    echo "$ICON ${SPEED}KB/s"
    exit 0
  fi
fi

# Then try Wi-Fi
if [ -d "/sys/class/net/$WIFI_IF" ] && ip link show "$WIFI_IF" | grep -q "state UP"; then
  SPEED=$(get_total_speed "$WIFI_IF")
  if [ "$SPEED" -gt 0 ]; then
    echo "$ICON ${SPEED}KB/s"
    exit 0
  fi
fi

# If no active traffic
echo "$DEFAULT_OUTPUT"

