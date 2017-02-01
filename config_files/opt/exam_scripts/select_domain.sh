#!/bin/bash
#set -x

source ${BASH_SOURCE%/*}/exam_conf.sh
source ${scripts_dir}/functions.sh

domains=$(dig -t TXT +short "${exam_domain_cfg}" | grep examdomains | cut -d '"' -f2 | cut -d'=' -f2)
if [ -z "$domains" ]; then
    show_error_message 'select_domain_title' 'unknown_domains' "${exam_domain_cfg}"
    exit 1
fi

title=$(get_string 'select_domain_title')
column=$(get_string 'domains')
text=$(get_string 'select_domain_msg')
domain=$(zenity --list --title="$title" --text="$text" --column="$column" $domains)
if [ -z "$domain" ]; then
    show_error_message 'select_domain_title' 'no_selected_domain'
    exit 1
fi

if [ "$domain" == "$exam_domain" ]; then
    show_error_message 'select_domain_title' 'domain_already_selected' "${domain}"
    exit 1
fi

cfgurl=$(dig -t TXT +short "${domain}" | grep examcfg | cut -d '"' -f2 | cut -d'=' -f2)
if [ -z "$cfgurl" ]; then
    show_error_message 'select_domain_title' 'no_domain_cfg' "${domain}"
    exit 1
fi

echo "$domain" > $user_domain_file

show_info_message 'select_domain_title' 'domain_selected' "${domain}"

exit 0
