#!/bin/bash
#set -x

source ${BASH_SOURCE%/*}/exam_conf.sh
source ${scripts_dir}/functions.sh

if ! network_isup; then
    show_error_message 'network_diagnostics' 'if_not_configured'
    exit 1
fi

router_ip=$(ip -f inet route |grep -E '^default' | cut -d' ' -f3)
ping -w 5 -c1 "${router_ip}" > /dev/null 2>&1
if [ "$?" != "0" ]; then
    show_error_message 'network_diagnostics' 'router_ip_unreachable' "${router_ip}"
    exit 1
fi

ping -w 5 -c1 "${ip_for_check}" > /dev/null 2>&1
if [ "$?" != "0" ]; then
    show_error_message 'network_diagnostics' 'ip_unreachable' "${ip_for_check}"
    exit 1
fi

ip=$(dig -t A +short "${hostname_for_check}" |grep -E '^[0-9].*[0-9]$' | tail -n1)
if [ -z "$ip" ]; then
    show_error_message 'network_diagnostics' 'dns_problem' "${hostname_for_check}"
    exit 1
fi

if [[ ! "${exam_server_url}" =~ ^http(s)?:// ]] ; then
    show_error_message 'network_diagnostics' 'bad_url' "${server_hostname}"
    exit 1
fi

server_hostname=$(echo "${exam_server_url}" | cut -d'/' -f3)
ip=$(dig -t A +short "${server_hostname}" |grep -E '^[0-9].*[0-9]$' | tail -n1)
if [ -z "${ip}" ]; then
    show_error_message 'network_diagnostics' 'dns_problem' "${server_hostname}"
    exit 1
fi

cres=$(curl --insecure --silent --max-time 15 -o /dev/null -L -w "%{http_code}" "${exam_server_url}")
if [ "$cres" == "000" ]; then
    show_error_message 'network_diagnostics' 'url_unreachable' "${exam_server_url}"
    exit 1
elif [ "$cres" != "200" ]; then
    show_error_message 'network_diagnostics' 'url_misconfigured' "${exam_server_url}" "${cres}"
    exit 1
fi

show_info_message 'network_diagnostics' 'network_ok' "${exam_server_url}"

exit 0
