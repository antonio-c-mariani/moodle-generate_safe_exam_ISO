#!/bin/bash

# $1 could be a domain to be configured

source ${BASH_SOURCE%/*}/exam_conf.sh
source ${scripts_dir}/functions.sh

if ! network_isup; then
    show_error_message 'select_domain_title' 'if_not_configured'
    exit 1
fi


if [ -f "$cfg_json" ]; then
    rm -f "$cfg_json"
fi

# Restore original iptable rules
/sbin/iptables-restore < ${rulesv4}.tpl
/sbin/ip6tables-restore < ${rulesv6}.tpl

# Get allowed domains fom DNS TXT record (examdomains)
domains=""
if [ -n "${exam_domain_cfg}" ]; then
    domains=$(dig -t TXT +short "${exam_domain_cfg}" | grep examdomains | cut -d '"' -f2 | cut -d'=' -f2)
fi

# Check and select the domain passed as argument
domain=""
if [ "$1" != "" ]; then
    domain=$1
    log "Processing domain '$domain'"
    numlines=$(echo "$domains" | tr -s " " "\n" | grep -c -x "$domain")
    if [ $numlines -eq 1 ]; then
        exam_domain=$domain
    else
        ${scripts_dir}/configure_firewall.sh
        show_error_message 'select_domain_title' 'unknown_domain' "$domain"
        exit 1
    fi
fi

# Select a default domain if it's not previously selected
if [ -z "$exam_domain" ]; then
    exam_domain=$(echo "$domains" | cut -d' ' -f1)
    if [ -z "$exam_domain" ]; then
        exam_domain=$exam_domain_cfg
    fi
fi

log "Configuring exam domain = '$exam_domain'"

# Searching for domain configuration
if [ -n "$exam_domain" ]; then
    cfgurl=$(dig -t TXT +short "${exam_domain}" | grep examcfg | cut -d '"' -f2 | cut -d'=' -f2)
    if [ -n "${cfgurl}" ] ; then
        cfghostname=$(echo "${cfgurl}" | cut -d'/' -f3)
        ip=$(dig -t A +short "${cfghostname}" | grep -E '^[0-9].*[0-9]$' | tail -n1)
        if [ -z "${ip}" ] ; then
            ${scripts_dir}/configure_firewall.sh
            show_error_message 'select_domain_title' 'no_ip_for' "${cfghostname}"
            exit 1
        else
            if [[ "${cfgurl}" =~ ^https ]] ; then
                port=443
            else
                port=80
            fi
            # Permit access to get the configuration
            iptables -A OUTPUT -d "${ip}" -p tcp --dport ${port} -j ACCEPT
        fi
    
        header1="EXAM-VERSION:${exam_version}"
        timeout=10
        if /usr/bin/curl --insecure --silent --connect-timeout $timeout --header "${header1}" -o $cfg_json "${cfgurl}"; then
            if grep -q "exam_description" $cfg_json ; then
                exam_description=$(get_json_param $cfg_json 'exam_description' $exam_description)
                institution_acronym=$(get_json_param $cfg_json 'institution_acronym' $institution_acronym)
                institution_name=$(get_json_param $cfg_json 'institution_name' $institution_name)
                contact_email=$(get_json_param $cfg_json 'contact_email' $contact_email)
                exam_server_url=$(get_json_param $cfg_json 'exam_server_url' $exam_server_url)
                send_data_path=$(get_json_param $cfg_json 'send_data_path' $send_data_path)
                allowed_tcp_out_ipv4=$(get_json_param $cfg_json 'allowed_tcp_out_ipv4' $allowed_tcp_out_ipv4)
                allowed_tcp_out_ipv6=$(get_json_param $cfg_json 'allowed_tcp_out_ipv6' $allowed_tcp_out_ipv6)
            else
                ${scripts_dir}/configure_firewall.sh
                show_error_message 'select_domain_title' 'invalid_json' "${cfgurl}"
                exit 1
            fi
        else
            ${scripts_dir}/configure_firewall.sh
            show_error_message 'select_domain_title' 'cfgurl_timeout' "${cfgurl}" "${timeout}"
            exit 1
        fi
    fi
fi

server_hostname=$(echo "${exam_server_url}" | cut -d'/' -f3)
server_ip=$(dig -t A +short "${server_hostname}" | grep -E '^[0-9].*[0-9]$' | tail -n1)

log "Server hostname = '$server_hostname' IP = '$server_ip'"

if [ -n "${server_ip}" ]; then
    local_ip=$(ip -f inet route get ${server_ip} | grep -o 'src.*' | cut -d ' ' -f 2)
    local_network=$(ip route | grep ${local_ip} | cut -d ' ' -f 1)

    # Adjust Firefox configuration
    sed "s|%exam_server_url%|${exam_server_url}|" /etc/firefox/syspref.js.tpl > /etc/firefox/syspref.js

    sed -e "s|%exam_version%|${exam_version}|" \
        -e "s|%exam_ip%|${local_ip}|" \
        -e "s|%exam_network%|${local_network}|" /usr/lib/firefox/firefox.cfg.tpl > /usr/lib/firefox/firefox.cfg

    # Rebuild the $params_cfg file
    echo "#!/bin/bash
exam_domain=\"$exam_domain\"
exam_description=\"$exam_description\"
institution_acronym=\"$institution_acronym\"
institution_name=\"$institution_name\"
contact_email=\"$contact_email\"
exam_server_url=\"$exam_server_url\"
send_data_path=\"$send_data_path\"
allowed_tcp_out_ipv4=\"$allowed_tcp_out_ipv4\"
allowed_tcp_out_ipv6=\"$allowed_tcp_out_ipv6\"
server_ip=\"$server_ip\"
" > $params_cfg

    # Add 'select_domain' option to Desktop if there are more than one allowed domains
    num_domains=$(echo "$domains" | wc -w)
    tm=$(uptime -p | cut -d' ' -f2)
    seldesk=${user_home}/Desktop/$select_desktop
    if [ $num_domains -lt 2 ] || [ $tm -gt 10 ]; then
        if [ -f ${seldesk} ]; then
           rm -f ${seldesk}
        fi
        cronsel=''
    else
        cp $scripts_dir/$select_desktop ${seldesk}
        select_domain_txt=$(get_string 'select_domain')
        sed -i "s/^Name=.*/Name=${select_domain_txt}/" ${seldesk}
        cronsel="* * * * * ${scripts_dir}/cron_select_domain.sh > /dev/null 2>&1"
    fi

    # Register cron actions
    echo -e "SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
*/3 * * * * ${scripts_dir}/send_data.sh > /dev/null 2>&1
${cronsel}" | crontab -u root -

    ${scripts_dir}/update_desktop_wallpaper.sh
    ${scripts_dir}/configure_firewall.sh
    show_info_message 'select_domain_title' 'domain_activated' "$exam_domain"
    ${scripts_dir}/send_data.sh
else
    ${scripts_dir}/configure_firewall.sh
    show_error_message 'select_domain_title' 'dns_problem' "$server_hostname"

    # There are at most 1 domain and for some reason the server_hostname could not be resolved. Keep trying...
    num_domains=$(echo "$domains" | wc -w)
    if [ $num_domains -lt 2 ]; then
        echo "$exam_domain" > $user_domain_file
        cronsel="* * * * * ${scripts_dir}/cron_select_domain.sh > /dev/null 2>&1"
        crontab -l -u root | grep -v cron_select_domain.sh | { cat; echo "$cronsel"; } | crontab -u root -
    fi

    exit 1
fi

exit 0
