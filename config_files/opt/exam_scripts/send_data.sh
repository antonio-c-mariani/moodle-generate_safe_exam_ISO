#!/bin/bash
#set -x

source ${BASH_SOURCE%/*}/exam_conf.sh
source ${scripts_dir}/functions.sh

if [ -n "${server_ip}" ] && ping -w 2 -c1 "${server_ip}" > /dev/null 2>&1 ; then
    # Exam server is reachable

    local_ip=$(ip -f inet route get ${server_ip} | grep -o 'src.*' | cut -d ' ' -f 2)
    local_network=$(ip route | grep ${local_ip} | cut -d ' ' -f 1)

    header1="EXAM-VERSION:${exam_version}"
    header2="EXAM-IP:${local_ip}"
    header3="EXAM-NETWORK:${local_network}"

    url="${exam_server_url}${send_data_path}"
    /usr/bin/curl --silent --insecure --max-time 30 --header "${header1}" --header "${header2}" --header "${header3}" "$url" > /dev/null 2>&1
    exit $?
fi

exit 1
