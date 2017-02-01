#!/bin/bash
#set -x

source ${BASH_SOURCE%/*}/exam_conf.sh
source ${scripts_dir}/functions.sh

# Check to see if a domain was selected
if [ -f "$user_domain_file" ]; then
    domain=$(cat $user_domain_file)
    log "Selecting domain: '$domain'"
    rm -f "$user_domain_file"
    $scripts_dir/configure_exam.sh "$domain"
else
    # Remove option to select domain after $select_domain_limit minutes
    tm=$(uptime -p | cut -d' ' -f2)
    if [ $tm -gt $select_domain_limit ]; then
        rm -f $user_home/Desktop/$select_desktop
        crontab -l | grep -v cron_select_domain.sh | crontab -
    fi
fi

exit 0
