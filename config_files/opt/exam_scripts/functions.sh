#!/bin/bash

touch $log_file
chown ubuntu $log_file

network_isup() {
    ip_for_test="1.1.1.1"

    local_route=$(ip route | grep default | grep -v linkdown)
    if [ -z "${local_route}" ]; then
        log "There is no default route or the link is down"
        return 1
    fi

    local_ip=$(ip -f inet route get $ip_for_test | grep -o 'src.*' | cut -d ' ' -f 2)
    if [ -z "${local_ip}" ]; then
        log "There is no route for $ip_for_test"
        return 1
    fi

    local_network=$(ip route | grep "${local_ip}" | cut -d ' ' -f 1)
    if [ "${local_network}" = "169.254.0.0/16" ]; then
        log "Fake network: unable to contact a DHCP server (see RFC 3927)"
        return 1
    fi

    log "Network is ok"
    return 0
}

log() {
    log_msg="${0##*/} $1"
    date="$(date +"%F %T,%N")"
    echo "${date:0:23} $log_msg" >> $log_file
}

get_json_param() {
    json_file=$1
    param=$2
    default=$3

    value=$(/usr/bin/jq ".${param}" $json_file)
    if [ "$value" = "null" ] ; then
        echo $default
    else
        value=$(echo $value | cut -d'"' -f2)
        echo $value
    fi
}

get_string() {
    str="???"
    if [ "$1" != "" ]; then
        lang=$(grep -e '^LANG=' /etc/default/locale | cut -d'=' -f2 | cut -d'_' -f1)
        str=$(grep -E "^${lang},$1=" ${message_file} | cut -d'=' -f2)
        if [ -z "$str" ]; then
            str=$(grep -E "^en,$1=" ${message_file} | cut -d'=' -f2)
            if [ -z "$str" ]; then
                str="???"
            fi
        fi
    fi

    str="${str/\%arg1\%/$2}"
    str="${str/\%arg2\%/$3}"

    echo $str
}

show_error_message() {
    title=$(get_string "$1")
    msg=$(get_string "$2" "$3" "$4")
    log "ERROR: $title - $msg"
    zenity --error --title "$title" --text "$msg" --display=:0.0
}

show_info_message() {
    title=$(get_string "$1")
    msg=$(get_string "$2" "$3" "$4")
    log "INFO: $title - $msg"
    zenity --info --title "$title" --text "$msg" --display=:0.0
}
