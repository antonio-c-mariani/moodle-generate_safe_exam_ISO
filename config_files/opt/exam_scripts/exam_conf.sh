#!/bin/bash

# ------------------------------------------------------------------
# Session 1: General 
# ------------------------------------------------------------------
exam_version='3.3'			    # Version of this CD

exam_domain_cfg="inf.ufsc.br"               # Where to find de exam domain list (DNS RR TXT 'examdomains')
                                            # Each domains must have an exam configuration url (DNS RR TXT 'examcfg')

ip_for_check="150.162.1.33"                 # Used for ping tests
hostname_for_check="www.brasil.gov.br"      # Used for DNS resolution tests

# ------------------------------------------------------------------
# Session 2: Institution data
# ------------------------------------------------------------------
exam_domain=""
exam_description="Moodle Exams"
institution_name="My Institution"
institution_acronym="MyIt"
contact_email="contact@my-institution.org"
exam_server_url="https://exam-myinstitution.org" # URL of the Moodle Exam

# Extra hosts (ips) and TCP ports to be accessed (need to be open on the local firewall)
# List of pairs (IP#port)

# allowed_tcp_out_ipv4="192.168.1.1#443 192.168.1.2#80"
allowed_tcp_out_ipv4=""

# allowed_tcp_out_ipv6="2801:84:0:1001:192:168:1:3#443"
allowed_tcp_out_ipv6=""

# ------------------------------------------------------------------
# Session 3: Internal data
# ------------------------------------------------------------------
scripts_dir="/opt/exam_scripts"
cfg_json="/tmp/cfg.json"
wallpaper="/opt/exam_scripts/images/wallpaper.png"
select_desktop="Desktop/select_domain.desktop"
user_domain_file="/home/ubuntu/.exam_domain"
rulesv4="/etc/iptables/rules.v4"
rulesv6="/etc/iptables/rules.v6"
params_cfg=${scripts_dir}/exam_params.sh
select_domain_limit=10 # After this time (minutes) a new domain can no longer be selected
send_data_path="/local/exam_authorization/receive_data.php"
server_ip=""

source ${params_cfg}
