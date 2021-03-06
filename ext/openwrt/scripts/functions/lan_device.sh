#!/bin/sh
# Copyright (C) 2012-2014 PIVA Software <www.pivasoftware.com>
# 	Author: MOHAMED Kallel <mohamed.kallel@pivasoftware.com>
# 	Author: AHMED Zribi <ahmed.zribi@pivasoftware.com>
# Copyright (C) 2011-2012 Luka Perkov <freecwmp@lukaperkov.net>


get_wlan_enable() {
local parm="InternetGatewayDevice.LANDevice.1.WLANConfiguration.$1.Enable"
local uci_iface="$2"
local nl="$3"
local type="xsd:boolean"
local val=""
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET wireless.${uci_iface}.disabled 2> /dev/null`
	[ "$val" = "1" ] && val="false" || val="true"
	;;
	get_name)
	[ "$nl" = "1" ] && return $E_INVALID_ARGUMENTS
	;;
	get_notification)
	easycwmp_get_parameter_notification "val" "$parm"
	;;
esac
easycwmp_output "$parm" "$val" "$permissions" "$type"
return 0
}

get_wlan_enable_all() {
	local nl="$1"
	local iface
	local ifaces=`$UCI_SHOW wireless| grep "wireless\.@wifi-iface\[[0-9]\+\]\.instance" | cut -d'.' -f2`
	for iface in $ifaces; do
		local num=`$UCI_GET wireless.$iface.instance`
		get_wlan_enable "$num" "$iface" "$nl"
	done
}

set_wlan_enable() {
local parm="InternetGatewayDevice.LANDevice.1.WLANConfiguration.$1.Enable"
local uci_iface="$2"
local val="$3"
case $action in
	set_value)
	[ "$val" = "1" -o "$val" = "true" ] && val="0" || val="1"
	execute_command_in_apply_service "wifi"
	$UCI_SET wireless.${uci_iface}.disabled="$val"
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_wlan_ssid() {
local parm="InternetGatewayDevice.LANDevice.1.WLANConfiguration.$1.SSID"
local uci_iface="$2"
local nl="$3"
local val=""
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET wireless.$uci_iface.ssid 2> /dev/null`
	;;
	get_name)
	[ "$nl" = "1" ] && return $E_INVALID_ARGUMENTS
	;;
	get_notification)
	easycwmp_get_parameter_notification "val" "$parm"
	;;
esac
easycwmp_output "$parm" "$val" "$permissions"
return 0
}

get_wlan_ssid_all() {
	local nl="$1"
	local iface
	local ifaces=`$UCI_SHOW wireless| grep "wireless\.@wifi-iface\[[0-9]\+\]\.instance" | cut -d'.' -f2`
	for iface in $ifaces; do
		local num=`$UCI_GET wireless.$iface.instance`
		get_wlan_ssid "$num" "$iface" "$nl"
	done
}

set_wlan_ssid() {
local parm="InternetGatewayDevice.LANDevice.1.WLANConfiguration.$1.SSID"
local uci_iface="$2"
local val="$3"
case $action in
	set_value)
	execute_command_in_apply_service "wifi"
	$UCI_SET wireless.$uci_iface.ssid="$val"
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

add_wlan_iface() {
	local instance=`get_max_instance`
	local wifi_device=`$UCI_GET wireless.@wifi-iface[0].device || echo radio0`
	local wifi_iface=`$UCI_ADD wireless wifi-iface`
	$UCI_SET wireless.$wifi_iface.device=$wifi_device
	$UCI_SET wireless.$wifi_iface.network=lan
	$UCI_SET wireless.$wifi_iface.encryption=none
	$UCI_SET wireless.$wifi_iface.mode=ap
	$UCI_SET wireless.$wifi_iface.instance=$((++instance))
	$UCI_SET wireless.$wifi_iface.disabled=1
	$UCI_COMMIT
	execute_command_in_apply_service "wifi"
	echo $instance
}

delete_wlan_iface() {
	$UCI_DELETE wireless.$1
	$UCI_COMMIT
	execute_command_in_apply_service "wifi"
}

get_wlan_configuration_instances() {
	local nl="$1"
	[ "$action" != "get_name" -o "$nl" = "1" ] && return
	local num
	local instances=`$UCI_SHOW wireless| grep "wireless\.@wifi-iface\[[0-9]\+\]\.instance" | cut -d'=' -f2`
	for num in $instances; do
		easycwmp_output "InternetGatewayDevice.LANDevice.1.WLANConfiguration.$num." "" "1"
	done
} 

get_wlan_num_and_uci_iface() {
	local parm="$1"
	local parm_check="$2"
	easycwmp_parse_formated_parameter "$parm" "$parm_check" "rc" "__num"
	[ "$rc" != "0" ] && return
	local __uci_iface=`$UCI_SHOW wireless | grep "wireless\.@wifi-iface\[[0-9]\+\].instance=$__num" | head -1 | cut -d'.' -f2`
	eval "export -- \"$3=\"\"$__num\"\"\""
	eval "export -- \"$4=\"\"$__uci_iface\"\"\""
}

get_max_instance() {
	local max=`$UCI_SHOW wireless | grep "wireless\.@wifi-iface\[[0-9]\+\].instance=" | cut -d'=' -f2 | sort -ru | head -1`
	echo ${max:-0}
}

get_lan_device_object() {
nl="$1"
case "$action" in
	get_name)
	[ "$nl" = "0" ] && easycwmp_output "InternetGatewayDevice.LANDevice." "" "0"
	;;
esac
}

get_lan_device_instance() {
nl="$1"
case "$action" in
	get_name)
	[ "$nl" = "0" ] && easycwmp_output "InternetGatewayDevice.LANDevice.1." "" "0"
	;;
esac
}

get_lan_device_wlan_configuration_object() {
nl="$1"
case "$action" in
	get_name)
	[ "$nl" = "0" ] && easycwmp_output "InternetGatewayDevice.LANDevice.1.WLANConfiguration." "" "1"
	;;
esac
}

get_lan_device_wlan_configuration_instance() {
param="$1"
nl="$2"
case "$action" in
	get_name)
	[ "$nl" = "0" ] && easycwmp_output "$param" "" "1"
	;;
esac
}

get_lan_device() {
case "$1" in
	InternetGatewayDevice.)
	get_lan_device_object 0
	get_lan_device_instance "$2"
	get_lan_device_wlan_configuration_object "$2"
	get_wlan_configuration_instances "$2"
	get_wlan_enable_all "$2"
	get_wlan_ssid_all "$2"
	return 0
	;;
	InternetGatewayDevice.LANDevice.)
	get_lan_device_object "$2"
	get_lan_device_instance 0
	get_lan_device_wlan_configuration_object "$2"
	get_wlan_configuration_instances "$2"
	get_wlan_enable_all "$2"
	get_wlan_ssid_all "$2"
	return 0
	;;
	InternetGatewayDevice.LANDevice.1.)
	get_lan_device_instance "$2"
	get_lan_device_wlan_configuration_object 0
	get_wlan_configuration_instances "$2"
	get_wlan_enable_all "$2"
	get_wlan_ssid_all "$2"
	return 0
	;;
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.)
	get_lan_device_wlan_configuration_object "$2"
	get_wlan_configuration_instances 0
	get_wlan_enable_all "$2"
	get_wlan_ssid_all "$2"
	return 0
	;;
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.[0-9].Enable)
	get_wlan_num_and_uci_iface "$1" "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{i}.Enable" num uci_iface
	[ "$uci_iface" = "" -o "$num" = "" ] && return $E_INVALID_PARAMETER_NAME
	get_wlan_enable "$num" "$uci_iface" "$2"
	return $?
	;;
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.[0-9].SSID)
	get_wlan_num_and_uci_iface "$1" "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{i}.SSID" num uci_iface
	[ "$uci_iface" = "" -o "$num" = "" ] && return $E_INVALID_PARAMETER_NAME
	get_wlan_ssid "$num" "$uci_iface" "$2"
	return $?
	;;
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.[0-9].)
	get_wlan_num_and_uci_iface "$1" "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{i}." num uci_iface
	[ "$uci_iface" = "" -o "$num" = "" ] && return $E_INVALID_PARAMETER_NAME
	get_lan_device_wlan_configuration_instance "$1" "$2"
	get_wlan_enable "$num" "$uci_iface" 0
	get_wlan_ssid "$num" "$uci_iface" 0
	return 0
	;;
esac
return $E_INVALID_PARAMETER_NAME
}

set_lan_device() {
local num uci_iface
case "$1" in
	InternetGatewayDevice.LANDevice.|\
	InternetGatewayDevice.LANDevice.1.|\
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.|\
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.)
	[ "$action" = "set_value" ] && return $E_INVALID_PARAMETER_NAME
	easycwmp_set_parameter_notification "$1" "$2"
	return 0
	;;
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.[0-9].Enable)
	get_wlan_num_and_uci_iface "$1" "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{i}.Enable" num uci_iface
	[ "$uci_iface" = "" -o "$num" = "" ] && return $E_INVALID_PARAMETER_NAME
	set_wlan_enable "$num" "$uci_iface" "$2"
	return 0
	;;
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.[0-9].SSID)
	get_wlan_num_and_uci_iface "$1" "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{i}.SSID" num uci_iface
	[ "$uci_iface" = "" -o "$num" = "" ] && return $E_INVALID_PARAMETER_NAME
	set_wlan_ssid "$num" "$uci_iface" "$2"
	return 0
	;;
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.[0-9].)
	[ "$action" = "set_value" ] && return $E_INVALID_PARAMETER_NAME
	get_wlan_num_and_uci_iface "$1" "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{i}." num uci_iface
	[ "$uci_iface" = "" -o "$num" = "" ] && return $E_INVALID_PARAMETER_NAME
	easycwmp_set_parameter_notification "$1" "$2"
	return 0
	;;
esac
return $E_INVALID_PARAMETER_NAME
}

build_instances_lan_device() {
	local iface
	local ifaces=`$UCI_SHOW wireless | grep "wireless\.@wifi-iface\[[0-9]\+\]=wifi-iface" | cut -d'.' -f2 | cut -d'=' -f1`
	local instance=`get_max_instance`
	for iface in $ifaces; do
		if [ "`$UCI_GET wireless.$iface.instance`" = "" ]; then
			$UCI_SET wireless.$iface.instance=$((++instance))
			$UCI_COMMIT
		fi
	done
}


add_object_lan_device() {
case "$1" in
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.)
	local instance=`add_wlan_iface`
	easycwmp_set_parameter_notification "$1$instance." "0"
	easycwmp_status_output "" "" "1" "$instance"
	return 0
	;;
esac
return $E_INVALID_PARAMETER_NAME
}

delete_object_lan_device() {
local num uci_iface
case "$1" in
	InternetGatewayDevice.LANDevice.1.WLANConfiguration.[0-9].)
	get_wlan_num_and_uci_iface "$1" "InternetGatewayDevice.LANDevice.1.WLANConfiguration.{i}." num uci_iface
	[ "$uci_iface" = "" -o "$num" = "" ] && return $E_INVALID_PARAMETER_NAME
	delete_wlan_iface $uci_iface
	easycwmp_remove_parameter_notification "$1"
	easycwmp_status_output "" "" "1"
	return 0
	;;
esac
return $E_INVALID_PARAMETER_NAME
}

register_function lan_device
