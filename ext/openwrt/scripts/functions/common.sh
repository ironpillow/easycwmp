#!/bin/sh
# Copyright (C) 2012-2014 PIVA Software <www.pivasoftware.com>
# 	Author: MOHAMED Kallel <mohamed.kallel@pivasoftware.com>
# 	Author: AHMED Zribi <ahmed.zribi@pivasoftware.com>
# Copyright (C) 2011-2012 Luka Perkov <freecwmp@lukaperkov.net>

# TODO: merge this one somewhere in OpenWrt
uci_remove_list_element() {
	local option="$1"
	local value="$2"
	local list="$($UCI_GET get $option)"
	local elem

	$UCI_DELETE $option
	for elem in $list; do
		if [ "$elem" != "$value" ]; then
			$UCI_ADD_LIST $option=$elem
		fi
	done
}

easycwmp_output() {
if [ "$FLAGS_json" = "${FLAGS_TRUE}" ]; then
	local parameter="$1"
	local value="$2"
	local permissions="$3"
	local type="$4"
	local fault_code="$5"
	easycwmp_json_output "$parameter" "$value" "$permissions" "$type" "$fault_code"
fi
}

easycwmp_json_output() {

	local parameter="$1"
	local value="$2"
	local permissions="$3"
	local type="$4"
	local fault_code="$5"

	[ "$type" = "" ] &&	type="xsd:string"

	json_init
	json_add_string "parameter" "$parameter"
    json_add_string "fault_code" "$fault_code"
	case "$action" in
		get_value)
		json_add_string "value" "$value"
		json_add_string "type" "$type"
		;;
		get_name)
		json_add_string "writable" "$permissions"
		;;
		get_notification)
		json_add_string "notification" "$value"
		;;
	esac
	json_close_object
	local msg=`json_dump`
	echo "$msg"
}

easycwmp_status_output() {
	local parameter="$1"
	local fault_code="$2"
	local status="$3"
	local instance="$4"
	
	json_init
	[ "$parameter" != "" ] && json_add_string "parameter" "$parameter"
	[ "$fault_code" != "" ] && json_add_string "fault_code" "$fault_code"
	[ "$status" != "" ] && json_add_string "status" "$status"
	[ "$instance" != "" ] && json_add_string "instance" "$instance"
	[ "$easycwmp_config_changed" = "1" ] && json_add_string "config_load" "1"
	json_close_object
	local msg=`json_dump`
	echo "$msg"
}

easycwmp_parse_formated_parameter() {
	local _clean_parameter="$1"
	local _formated_parameter="$2"
	local _values
	
	if [ "${_formated_parameter#${_formated_parameter%?}}" != "${_clean_parameter#${_clean_parameter%?}}" -o\
		"${_clean_parameter//../}" != "$_clean_parameter" ]; then
		eval "export -- \"$3=-1\""
		return
	fi

	local _clean_parameter_array=`echo $_clean_parameter | sed 's/\./ /g'`
	local _formated_parameter_array=`echo $_formated_parameter | sed 's/\./ /g'`
	
	if [  "`echo $_clean_parameter_array | wc -w`" != "`echo $_formated_parameter_array | wc -w`" ]; then
		eval "export -- \"$3=-1\""
		return
	fi
	
	local i
	local j=0
	for i in $_formated_parameter_array
	do
		let j=$j+1
		if [ "x$i" == "x{i}" ]; then
			# get value for sections maked as {i}
			local m
			local n=0
			for m in $_clean_parameter_array
			do
				let n=$n+1
				if [ $n -eq $j ]; then
					if [ "x$_values" == "x" ]; then
						_values="$m"
					else
						_values="$_values $m"
					fi
				fi
			done
		else
			# check if sections not marked as {i} match
			local m
			local n=0
			for m in $_clean_parameter_array
			do
				let n=$n+1
				if [ $n -eq $j -a "x$m" != "x$i" ]; then
					eval "export -- \"$3=-1\""
					return
				fi
			done
		fi
	done

	eval "export -- \"$3=0\""
	eval "export -- \"$4=\"\"$_values\"\"\""
}

easycwmp_config_cwmp() {
	config_get __parameter "$1" "parameter"
	config_get __value "$1" "value"

	if [ "$__parameter" = "$4" ]; then
		if [ "get" = "$2" ]; then
			if [ "value" = "$3" ]; then
				eval "export -- \"$5=\"\"$__value\"\"\""
			fi
		elif [ "set" = "$2" ]; then
			if [ "value" = "$3" ]; then
				$UCI_SET easycwmp.$1.value=$5 2> /dev/null
			fi
		elif [ "check" = "$2" ]; then
			if [ "parameter" = "$3" ]; then
				eval "export -- \"$5=\"$1\"\""
			fi
		fi
	fi
}

easycwmp_config_notifications() {
	config_get __active "$1" "active"
	config_get __passive "$1" "passive"

	for item in $__active
	do
		if [ "$item" = "$3" ]; then
			eval "export -- \"$4=2\""
			return 0
		elif [ "`echo $3|grep $item`" = "$3" ]; then
			eval "export -- \"$4=2\""
			return 0
		fi
	done
	for item in $__passive
	do
		if [ "$item" = "$3" ]; then
			eval "export -- \"$4=1\""
			return 0
		elif [ "`echo $3|grep $item`" = "$3" ]; then
			eval "export -- \"$4=1\""
			return 0
		fi
	done
}

easycwmp_get_parameter_value() {
	local _dest="$1"
	local _parm="$2"
	local _val
	config_load easycwmp
	config_foreach easycwmp_config_cwmp "cwmp" "get" "value" "$_parm" "_val"
	eval "export -- \"$_dest=\"\"$_val\"\"\""
}

easycwmp_set_parameter_value() {
	local _parm="$1"
	local _val="$2"
	config_load easycwmp
	config_foreach easycwmp_config_cwmp "cwmp" "check" "parameter" "$_parm" "_section"
	if [ ! "$_section" = "" ]; then
		$UCI_SET easycwmp.$_section.value=$_val 2> /dev/null
	else
		$UCI_BATCH << EOF 2>&1 >/dev/null
			add easycwmp cwmp
			set easycwmp.@cwmp[-1].parameter="$_parm"
			set easycwmp.@cwmp[-1].value="$_val"
EOF
	fi
	config_foreach easycwmp_config_notifications "notifications" "get" "$_parm" "tmp"
}

easycwmp_get_parameter_notification() {
	local _dest="$1"
	local _parm="$2"
	local _val=0
	local p ntype len maxlen=0
	
	for ntype in "active:2" "passive:1" "none:0"; do
		local list_notif=`$UCI_GET easycwmp.@notifications[0].${ntype%:*}`
		for p in $list_notif; do
			if [ "$p" = "$_parm" ]; then
				_val=${ntype#*:}
				eval "export -- \"$_dest=$_val\""
				return
			fi
			case $p in
				*.)
				case $_parm in
					$p*)
					len=${#p}
					if [ $len -gt $maxlen ]; then
						_val=${ntype#*:}
						maxlen=$len
					fi
				esac
				;;
			esac
		done
	done
	eval "export -- \"$_dest=$_val\""
}

easycwmp_remove_parameter_notification() {
	local _parm="$1"
	local ntype
	for ntype in active passive none; do
		case $_parm in
			*.)
			local list_del=`$UCI_GET easycwmp.@notifications[0].$ntype`
			local del
			for del in $list_del; do
				case $del in
					$_parm*)
					$UCI_DEL_LIST easycwmp.@notifications[0].$ntype=$del 2>/dev/null
					;;
				esac
			done
			;;
			*)
			$UCI_DEL_LIST easycwmp.@notifications[0].$ntype=$_parm 2>/dev/null
			;;
		esac
	done
}

easycwmp_set_parameter_notification() {
	local _parm="$1"
	local _val="$2"
	local tmp=`$UCI_GET easycwmp.@notifications[0] 2>/dev/null`
	if [ "$tmp" = "" ]; then
		$UCI_ADD easycwmp notifications 2>&1 >/dev/null
	else
		easycwmp_remove_parameter_notification $_parm
	fi
	local notif
	easycwmp_get_parameter_notification notif $_parm
	[ "$notif" = "$_val" ] && return
	if [ "$_val" -eq "1" ]; then
		$UCI_ADD_LIST easycwmp.@notifications[0].passive="$_parm" 2>&1 >/dev/null
	elif [ "$_val" -eq "2" ]; then
		$UCI_ADD_LIST easycwmp.@notifications[0].active="$_parm" 2>&1 >/dev/null
	elif [ "$_val" -eq "0" ]; then
		local list_prm="`$UCI_GET easycwmp.@notifications[0].active` `$UCI_GET easycwmp.@notifications[0].passive`"
		for prm in $list_prm; do
			case $prm in
				*.)
				case $_parm in
					$prm*)
					$UCI_ADD_LIST easycwmp.@notifications[0].none="$_parm" 2>&1 >/dev/null
					break
					;;
				esac
				;;
			esac
		done
	fi
}

delay_service_restart_in_apply_service() {
local service="$1"
local delay="$2"
[ "`cat $apply_service_tmp_file 2>/dev/null | grep /etc/init.d/$service`" != "" ] && return
cat >> "$apply_service_tmp_file" <<EOF
/etc/init.d/$service stop >/dev/null 2>/dev/null
sleep $delay
/etc/init.d/$service start >/dev/null 2>/dev/null
EOF
}

execute_command_in_apply_service() {
local command="$1"
local chk=`cat "$apply_service_tmp_file" 2>/dev/null | grep "^$command "`
[ "$chk" != "" ] && return
cat >> "$apply_service_tmp_file" <<EOF
$command >/dev/null 2>/dev/null
EOF
}

easycwmp_set_parameter_fault() {
	local _parm="$1"
	local _fault="$2"
	easycwmp_output "$_parm" "" "" "" "$_fault" >> $set_fault_tmp_file
}

easycwmp_execute_functions()
{
	local function_list="$1"
	local arg1="$2"
	local arg2="$3"
	local arg3="$4"
	local no_fault="0"
	local fault_code=""

	for function_name in $function_list
	do
		$function_name "$arg1" "$arg2" "$arg3"
		fault_code="$?"
		if [ "$fault_code" = "0" ]; then
			no_fault="1"
		fi
		if [ "$fault_code" != "0" -a "$fault_code" != "$E_INVALID_PARAMETER_NAME" ]; then
			return $fault_code
		fi
	done
	if [ "$no_fault" = "1" ]; then fault_code="0"; fi
	return $fault_code
}

easycwmp_get_inform_parameters()
{
	action="get_value"
	get_device_info_manufacturer
	get_device_info_oui
	get_device_info_product_class
	get_device_info_serial_number
	get_device_info_hardware_version
	get_device_info_software_version
	get_management_server_connection_request_url
	get_wan_device_mng_interface_ip
	get_device_info_specversion
	get_device_info_provisioningcode
	get_management_server_parameterkey
}

easycwmp_get_inform_deviceid()
{
	local msg
	json_init
	
	json_add_string "manufacturer" "`cat /tmp/sysinfo/model | cut -d' ' -f1`"
    json_add_string "oui" "`uci get wireless.radio0.macaddr | tr 'a-f' 'A-F' | tr -d ':' | cut -c 1-6`"
    json_add_string "product_class" "`cat /tmp/sysinfo/board_name`"
    json_add_string "serial_number" "`uci get wireless.radio0.macaddr | tr 'a-f' 'A-F' | tr -d ':'`"
    
	json_close_object
	local msg=`json_dump`
	echo "$msg"
}

easycwmp_config_load() {
	easycwmp_config_changed="1"
}
