#!/usr/bin/bash

# Config
#==========================================================
SCRIPTPATH="$(cd "$(dirname "$0")" || exit && pwd -P)"
# Config for rofi-wifi-menu
# position values:
# 1 2 3
# 8 0 4
# 7 6 5
POSITION=2
#x-offset
X_OFFSET=355
#y-offset
Y_OFFSET=50
#font
FONT="JetBrainsMono Nerd Font 10"
#==========================================================

DEVICES="$(bluetoothctl devices | awk '{print $3,$2}')"

SELECTED="$(printf "%s" "$DEVICES" | rofi -dmenu -p "Devices: " -matching regex -config "$SCRIPTPATH/bluetoothctl_config.rasi" -location "$POSITION" -yoffset "$Y_OFFSET" -xoffset "$X_OFFSET" -font "$FONT")"

SELECTED_NAME="$(printf "%s" "$SELECTED" | awk '{print $1}')"
SELECTED_ID="$(printf "%s" "$SELECTED" | awk '{print $2}')"

CONNECT="$(printf "%s\n%s" "Connect" "Disconnect" | rofi -dmenu -p "$SELECTED_NAME" -matching regex -config "$SCRIPTPATH/bluetoothctl_config.rasi" -location "$POSITION" -yoffset "$Y_OFFSET" -xoffset "$X_OFFSET" -font "$FONT")"

if [[ "$CONNECT" =~ "Connect" ]]; then
	printf "%s" "working"
fi
