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

bluetooth_check() {

	CONNECTED="$(bluetoothctl devices Connected | awk '{print $3}')"
	if [[ -z "$CONNECTED" ]]; then
		printf " %s " ""
	else
		printf " %s %s" "" "$CONNECTED"
	fi

	if [[ "$(systemctl is-active "bluetooth.service")" =~ "inactive" ]]; then
		printf "%s" "  Service Down "
	fi

}

bluetooth_click() {

	CONTROLLER_INFO="$(bluetoothctl show)"

	DEVICES="$(bluetoothctl devices Paired | awk '{print $3,$2}')"

	SELECTED="$(printf "%s" "$DEVICES" | rofi -dmenu -p "Devices: " -matching regex -config "$SCRIPTPATH/bluetoothctl_config.rasi" -location "$POSITION" -yoffset "$Y_OFFSET" -xoffset "$X_OFFSET" -font "$FONT")"

	# Exit if no device is selected
	[[ -z "$SELECTED" ]] && exit 1

	SELECTED_NAME="$(printf "%s" "$SELECTED" | awk '{print $1}')"
	SELECTED_ID="$(printf "%s" "$SELECTED" | awk '{print $2}')"

	STATUS="$(bluetoothctl info "$SELECTED_ID")"

	if printf "%s" "$STATUS" | rg -q "Connected: yes"; then
		SELECTED_NAME="${SELECTED_NAME} (Connected)"
	fi

	ACTION="$(printf "%s\n%s" "Connect" "Disconnect" | rofi -dmenu -p "$SELECTED_NAME" -matching regex -config "$SCRIPTPATH/bluetoothctl_config.rasi" -location "$POSITION" -yoffset "$Y_OFFSET" -xoffset "$X_OFFSET" -font "$FONT")"

	if [[ "$ACTION" =~ "Connect" ]]; then
		bluetoothctl connect "$SELECTED_ID"
	elif [[ "$ACTION" =~ "Disconnect" ]]; then
		bluetoothctl disconnect "$SELECTED_ID"
	fi

}

case "$1" in
--click)
	bluetooth_click
	;;
*)
	bluetooth_check
	;;
esac
