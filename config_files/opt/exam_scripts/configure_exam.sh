#!/bin/bash

# $1 could be a domain to be configured

local_dir="${BASH_SOURCE%/*}"
source "${local_dir}/functions.sh"

if ! network_isup; then
    show_error_message 'select_domain_title' 'if_not_configured'
    exit 1
fi

source "${local_dir}/exam_conf.sh"

# Restore original iptable rules
/sbin/iptables-restore < ${rulesv4}.tpl
/sbin/ip6tables-restore < ${rulesv6}.tpl

# Get allowed domains fom DNS TXT record (examdomains)
domains=$(dig -t TXT +short "${exam_domain_cfg}" | grep examdomains | cut -d '"' -f2 | cut -d'=' -f2)

# Check and select the domain passed as argument
domain="$1"
if [ -n "$domain" ]; then
    numlines=$(echo "$domains" | tr -s " " "\n" | grep -c -x "$domain")
    if [ $numlines -eq 1 ]; then
        exam_domain=$domain
    else
        ${scripts_dir}/configure_firewall.sh
        show_error_message 'select_domain_title' 'unknown_domain' "${domain}"
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

# Searching for domain configuration
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
    /usr/bin/curl --insecure --silent --header "${header1}" -o $cfg_json "${cfgurl}"
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
fi

server_hostname=$(echo "${exam_server_url}" | cut -d'/' -f3)
server_ip=$(dig -t A +short "${server_hostname}" | grep -E '^[0-9].*[0-9]$' | tail -n1)

if [ -n "${server_ip}" ]; then
    local_ip=$(ip -f inet route get ${server_ip} | grep -o 'src.*' | cut -d ' ' -f 2)
    local_network=$(ip route | grep ${local_ip} | cut -d ' ' -f 1)

    # Adjust Firefox and Google Chrome configuration
    sed "s|%exam_server_url%|${exam_server_url}|" /etc/firefox/syspref.js.tpl > /etc/firefox/syspref.js
    pref='.config/google-chrome/Default/Preferences.tpl'
    sed "s|%exam_server_url%|${exam_server_url}|" /etc/skel/${pref} > /home/ubuntu/${pref}

    sed -e "s|%exam_version%|${exam_version}|" \
        -e "s|%exam_ip%|${local_ip}|" \
        -e "s|%exam_network%|${local_network}|" /usr/lib/firefox/firefox.cfg.tpl > /usr/lib/firefox/firefox.cfg

    # Rebuild the exam.conf.sh file
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
    if [ $num_domains -lt 2 ] || [ $tm -gt 10 ]; then
        rm -f /home/ubuntu/$select_desktop
        cronsel=''
    else
        cp /etc/skel/$select_desktop /home/ubuntu/$select_desktop
        select_domain_txt=$(get_string 'select_domain')
        sed -i "s/^Name=.*/Name=${select_domain_txt}/" /home/ubuntu/$select_desktop
        cronsel="* * * * * ${scripts_dir}/cron_select_domain.sh > /dev/null 2>&1"
    fi

    # Register cron actions
    echo -e "SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
*/3 * * * * ${scripts_dir}/send_data.sh > /dev/null 2>&1
${cronsel}" | crontab -u root -

    ${scripts_dir}/update_desktop_wallpaper.sh
    ${scripts_dir}/configure_firewall.sh
    show_info_message 'select_domain_title' 'domain_activated' "${exam_domain}"
    ${scripts_dir}/send_data.sh
else
    ${scripts_dir}/configure_firewall.sh
    show_error_message 'select_domain_title' 'dns_problem' "${server_hostname}"
    exit 1
fi

exit 0
