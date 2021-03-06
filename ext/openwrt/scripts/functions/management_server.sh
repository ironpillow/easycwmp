#!/bin/sh
# Copyright (C) 2012-2014 PIVA Software <www.pivasoftware.com>
# 	Author: MOHAMED Kallel <mohamed.kallel@pivasoftware.com>
# 	Author: AHMED Zribi <ahmed.zribi@pivasoftware.com>
# Copyright (C) 2011-2012 Luka Perkov <freecwmp@lukaperkov.net>

get_management_server_url() {
local nl="$1"
local val=""
local permissions="1"
local tmp_value=${FLAGS_value}
FLAGS_value=${FLAGS_TRUE}
local scheme=`$UCI_GET easycwmp.@acs[0].scheme 2> /dev/null`
local hostname=`$UCI_GET easycwmp.@acs[0].hostname 2> /dev/null`
local port=`$UCI_GET easycwmp.@acs[0].port 2> /dev/null`
local path=`$UCI_GET easycwmp.@acs[0].path 2> /dev/null`
FLAGS_value=$tmp_value
FLAGS_ubus=$tmp_ubus
local parm="InternetGatewayDevice.ManagementServer.URL"
case "$action" in
	get_value)
	val="$scheme://$hostname:$port$path"
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

set_management_server_url() {
local parm="InternetGatewayDevice.ManagementServer.URL"
case "$action" in
	set_value)
local url=$1
local scheme
local hostname
local path
local port

scheme=`echo $url | awk -F "://" '{ print $1 }'`
hostname=`echo $url | awk -F "$scheme://" '{ print $2 }' | awk -F ":" '{ print $1 }' | awk -F "/" '{ print $1 }'`
port=`echo $url | awk -F "$scheme://$hostname:" '{ print $2 }' | awk -F '/' '{ print $1 }'`

if [ -z "$port" ]; then
	port=80
	path=`echo $url | awk -F "$scheme://$hostname" '{ print $2 }'`
else
	path=`echo $url | awk -F "$scheme://$hostname:$port" '{ print $2 }'`
fi

if [ -z "$path" ]; then
	path="/"
fi

set_management_server_x_easycwmp_org__acs_scheme $scheme
set_management_server_x_easycwmp_org__acs_hostname $hostname
set_management_server_x_easycwmp_org__acs_port $port
set_management_server_x_easycwmp_org__acs_path $path
easycwmp_config_load
	;;
	set_notification)
	local val=$1
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_username() {
local nl="$1"
local val=""
local permissions="1"
local parm="InternetGatewayDevice.ManagementServer.Username"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].username 2> /dev/null`
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

set_management_server_username() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.Username"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@acs[0].username="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_password() {
local nl="$1"
local val=""
local permissions="1"
local parm="InternetGatewayDevice.ManagementServer.Password"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].password 2> /dev/null`
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

set_management_server_password() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.Password"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@acs[0].password="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_periodic_inform_enable() {
local nl="$1"
local val=""
local type="xsd:boolean"
local parm="InternetGatewayDevice.ManagementServer.PeriodicInformEnable"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].periodic_enable`
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

set_management_server_periodic_inform_enable() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.PeriodicInformEnable"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@acs[0].periodic_enable="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_periodic_inform_interval() {
local nl="$1"
local val=""
local type="xsd:unsignedInt"
local parm="InternetGatewayDevice.ManagementServer.PeriodicInformInterval"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].periodic_interval`
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

set_management_server_periodic_inform_interval() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.PeriodicInformInterval"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@acs[0].periodic_interval="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_connection_request_url() {
local nl="$1"
local val
local parm="InternetGatewayDevice.ManagementServer.ConnectionRequestURL"
local permissions="0"
case "$action" in
	get_value)
if [ -z "$default_management_server_connection_request_url" ]; then
		local intf=`$UCI_GET easycwmp.@local[0].interface 2> /dev/null`
		local ip=`ifconfig "$intf" | grep inet | sed 's/^ *//g' | cut -f 2 -d ' '|cut -f 2 -d ':'`
		local port=`$UCI_GET easycwmp.@local[0].port 2> /dev/null`

	if [ -n "$ip" -a -n "$port" ]; then
		val="http://$ip:$port/"
	fi
else
	val=$default_management_server_connection_request_url
fi
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

set_management_server_connection_request_url() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.ConnectionRequestURL"
case "$action" in
	set_value)
	return $E_NON_WRITABLE_PARAMETER
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
return 0
}

get_management_server_connection_request_username() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.ConnectionRequestUsername"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@local[0].username 2> /dev/null`
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

set_management_server_connection_request_username() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.ConnectionRequestUsername"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@local[0].username="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_connection_request_password() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.ConnectionRequestPassword"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@local[0].password 2> /dev/null`
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

set_management_server_connection_request_password() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.ConnectionRequestPassword"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@local[0].password="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

# TODO: InternetGatewayDevice.ManagementServer.PeriodicInformTime

get_management_server_x_easycwmp_org__acs_scheme() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Scheme"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].scheme 2> /dev/null`
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

set_management_server_x_easycwmp_org__acs_scheme() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Scheme"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@acs[0].scheme="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_x_easycwmp_org__acs_hostname() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Hostname"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].hostname 2> /dev/null`
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

set_management_server_x_easycwmp_org__acs_hostname() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Hostname"
case "$action" in
	set_value)
if [ -z "$default_management_server_acs_hostname" ]; then
			$UCI_SET easycwmp.@acs[0].hostname="$val"
else
		$UCI_SET easycwmp.@acs[0].hostname="$default_management_server_acs_hostname"
fi
easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_x_easycwmp_org__acs_port() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Port"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].port 2> /dev/null`
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

set_management_server_x_easycwmp_org__acs_port() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Port"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@acs[0].port="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_x_easycwmp_org__acs_path() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Path"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].path 2> /dev/null`
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

set_management_server_x_easycwmp_org__acs_path() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Path"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@acs[0].path="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_x_easycwmp_org__connection_request_port() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__Connection_Request_Port"
local permissions="1"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@local[0].port 2> /dev/null`
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

set_management_server_x_easycwmp_org__connection_request_port() {
local val=$1
local parm="InternetGatewayDevice.ManagementServer.X_easycwmp_org__Connection_Request_Port"
case "$action" in
	set_value)
	$UCI_SET easycwmp.@local[0].port="$val"
	easycwmp_config_load
	;;
	set_notification)
	easycwmp_set_parameter_notification "$parm" "$val"
	;;
esac
}

get_management_server_parameterkey() {
local nl="$1"
local val=""
local parm="InternetGatewayDevice.ManagementServer.ParameterKey"
local permissions="0"
case "$action" in
	get_value)
	val=`$UCI_GET easycwmp.@acs[0].parameter_key 2> /dev/null`
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

get_management_server_object() {
nl="$1"
case "$action" in
	get_name)
	[ "$nl" = "0" ] && easycwmp_output "InternetGatewayDevice.ManagementServer." "" "0"
	;;
esac
}


get_management_server() {
case "$1" in
	InternetGatewayDevice.)
	get_management_server_object 0
	get_management_server_url "$2"
	get_management_server_username "$2"
	get_management_server_password "$2"
	get_management_server_periodic_inform_enable "$2"
	get_management_server_periodic_inform_interval "$2"
	get_management_server_connection_request_url "$2"
	get_management_server_connection_request_username "$2"
	get_management_server_connection_request_password "$2"
	get_management_server_x_easycwmp_org__acs_scheme "$2"
	get_management_server_x_easycwmp_org__acs_hostname "$2"
	get_management_server_x_easycwmp_org__acs_port "$2"
	get_management_server_x_easycwmp_org__acs_path "$2"
	get_management_server_x_easycwmp_org__connection_request_port "$2"
	get_management_server_parameterkey "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.)
	get_management_server_object "$2"
	get_management_server_url 0
	get_management_server_username 0
	get_management_server_password 0
	get_management_server_periodic_inform_enable 0
	get_management_server_periodic_inform_interval 0
	get_management_server_connection_request_url 0
	get_management_server_connection_request_username 0
	get_management_server_connection_request_password 0
	get_management_server_x_easycwmp_org__acs_scheme 0
	get_management_server_x_easycwmp_org__acs_hostname 0
	get_management_server_x_easycwmp_org__acs_port 0
	get_management_server_x_easycwmp_org__acs_path 0
	get_management_server_x_easycwmp_org__connection_request_port 0
	get_management_server_parameterkey 0
	return 0
	;;
	InternetGatewayDevice.ManagementServer.URL)
	get_management_server_url "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.Username)
	get_management_server_username "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.Password)
	get_management_server_password "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.PeriodicInformEnable)
	get_management_server_periodic_inform_enable "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.PeriodicInformInterval)
	get_management_server_periodic_inform_interval "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.ConnectionRequestURL)
	get_management_server_connection_request_url "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.ConnectionRequestUsername)
	get_management_server_connection_request_username "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.ConnectionRequestPassword)
	get_management_server_connection_request_password "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Scheme)
	get_management_server_x_easycwmp_org__acs_scheme "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Hostname)
	get_management_server_x_easycwmp_org__acs_hostname "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Port)
	get_management_server_x_easycwmp_org__acs_port "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Path)
	get_management_server_x_easycwmp_org__acs_path "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__Connection_Request_Port)
	get_management_server_x_easycwmp_org__connection_request_port "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.ParameterKey)
	get_management_server_parameterkey "$2"
	return $?
	;;
esac
return $E_INVALID_PARAMETER_NAME
}

set_management_server() {
case "$1" in
	InternetGatewayDevice.|\
	InternetGatewayDevice.ManagementServer.)
	[ "$action" = "set_notification" ] && return $E_NOTIFICATION_REJECTED
	;;
	InternetGatewayDevice.ManagementServer.URL)
	set_management_server_url "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.Username)
	set_management_server_username "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.Password)
	set_management_server_password "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.PeriodicInformEnable)
	set_management_server_periodic_inform_enable "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.PeriodicInformInterval)
	set_management_server_periodic_inform_interval "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.ConnectionRequestURL)
	set_management_server_connection_request_url "$2"
	return $?
	;;
	InternetGatewayDevice.ManagementServer.ConnectionRequestUsername)
	set_management_server_connection_request_username "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.ConnectionRequestPassword)
	set_management_server_connection_request_password "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Scheme)
	set_management_server_x_easycwmp_org__acs_scheme "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Hostname)
	set_management_server_x_easycwmp_org__acs_hostname "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Port)
	set_management_server_x_easycwmp_org__acs_port "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__ACS_Path)
	set_management_server_x_easycwmp_org__acs_path "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.X_easycwmp_org__Connection_Request_Port)
	set_management_server_x_easycwmp_org__connection_request_port "$2"
	return 0
	;;
	InternetGatewayDevice.ManagementServer.ParameterKey)
	[ "$action" = "set_notification" ] && return $E_NOTIFICATION_REJECTED || return $E_NON_WRITABLE_PARAMETER
	;;
esac
return $E_INVALID_PARAMETER_NAME
}

build_instances_management_server() { return 0; }

add_object_management_server() { return $E_INVALID_PARAMETER_NAME; }

delete_object_management_server() { return $E_INVALID_PARAMETER_NAME; }

register_function management_server
