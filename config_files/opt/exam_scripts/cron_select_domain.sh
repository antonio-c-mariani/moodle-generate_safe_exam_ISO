#!/bin/bash
#set -x

local_dir="${BASH_SOURCE%/*}"
source "${local_dir}/exam_conf.sh"

# Check to see if a domain was selected
if [ -f $user_domain_file ]; then
    domain=$(cat $user_domain_file)
    if [ -n "$domain" ]; then
        $local_dir/configure_exam.sh "$domain"
    fi
    rm -f $user_domain_file
else
    # Remove option to select domain after $select_domain_limit minutes
    tm=$(uptime -p | cut -d' ' -f2)
    if [ $tm -gt $select_domain_limit ]; then
        rm -f /home/ubuntu/$select_desktop
        crontab -l | grep -v cron_select_domain.sh | crontab -
    fi
fi

exit 0
