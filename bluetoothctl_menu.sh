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

	if [[ "$(systemctl is-active "bluetooth.service")" =~ "inactive" ]]; then
		printf "%s" "  Service Down "
		exit 0
	fi

	if bluetoothctl show | rg -q "Powered: no"; then
		printf " %s " ""
		exit 0
	fi

	CONNECTED="$(bluetoothctl devices Connected | awk '{print $3}')"
	if [[ -z "$CONNECTED" ]]; then
		printf " %s " ""
	else
		printf " %s %s " "" "$CONNECTED"
	fi
}

is_powered() {
	if bluetoothctl show | rg -q "Powered: yes"; then
		return 0
	else
		return 1
	fi
}

bluetooth_power() {
	if is_powered; then
		bluetoothctl power off
	else
		if rfkill list bluetooth | rg -q 'blocked: yes'; then
			rfkill unblock bluetooth && sleep 3
		fi
		bluetoothctl power on
	fi
}

device_submenu() {

	DEVICE="$1"

	DEVICE_NAME="$(printf "%s" "$DEVICE" | awk '{print $1}')"
	DEVICE_ID="$(printf "%s" "$DEVICE" | awk '{print $2}')"

	STATUS="$(bluetoothctl info "$DEVICE_ID")"

	if printf "%s" "$STATUS" | rg -q "Connected: yes"; then
		DEVICE_NAME="${SELECTED_NAME} (Connected)"
	fi

	ACTION="$(printf "%s\n%s" "Connect" "Disconnect" | rofi -dmenu -p "$DEVICE_NAME" -matching regex -config "$SCRIPTPATH/bluetoothctl_config.rasi" -location "$POSITION" -yoffset "$Y_OFFSET" -xoffset "$X_OFFSET" -font "$FONT")"

	if [[ "$ACTION" =~ "Connect" ]]; then
		bluetoothctl connect "$DEVICE_ID"
	elif [[ "$ACTION" =~ "Disconnect" ]]; then
		bluetoothctl disconnect "$DEVICE_ID"
	fi

}

bluetooth_click() {

	EXIT="Exit"

	DEVICES_LIST="$(bluetoothctl devices Paired | awk '{print $3,$2}')"

	if bluetoothctl show | rg -q "Powered: yes"; then
		POWER="Power: OFF"
		OPTIONS="$DEVICES_LIST\n\n$POWER\n$EXIT"
	else
		POWER="Power: ON"
		OPTIONS="$POWER\n$EXIT"
	fi

	SELECTED_DEVICE="$(printf "%b" "$OPTIONS" | rofi -dmenu -p "Devices: " -matching regex -config "$SCRIPTPATH/bluetoothctl_config.rasi" -location "$POSITION" -yoffset "$Y_OFFSET" -xoffset "$X_OFFSET" -font "$FONT")"

	# Exit if no device is selected
	[[ -z "$SELECTED_DEVICE" ]] && exit 1

	if [[ "$SELECTED_DEVICE" == "$POWER" ]]; then
		bluetooth_power
		exit 0
	elif [[ "$SELECTED_DEVICE" == "$EXIT" ]]; then
		exit 0
	else
		device_submenu "$SELECTED_DEVICE"
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
