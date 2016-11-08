#!/bin/bash

# Version of this CD
exam_version='3.3'

exam_domain_cfg="inf.ufsc.br"               # Where to find de exam domain list (DNS RR TXT 'examdomains')
                                            # Each domains must have an exam configuration url (DNS RR TXT 'examcfg')
ip_for_check="150.162.1.33"                 # Used for ping tests
hostname_for_check="www.brasil.gov.br"      # Used for DNS resolution tests

scripts_dir="/opt/exam_scripts"
cfg_json="/tmp/cfg.json"
wallpaper="/opt/exam_scripts/images/wallpaper.png"
select_desktop="Desktop/select_domain.desktop"
user_domain_file="/home/ubuntu/.exam_domain"
rulesv4="/etc/iptables/rules.v4"
rulesv6="/etc/iptables/rules.v6"
params_cfg=${scripts_dir}/exam_params.sh
select_domain_limit=10                      # After this time (minutes) a new domain can no longer be selected

source ${params_cfg}
