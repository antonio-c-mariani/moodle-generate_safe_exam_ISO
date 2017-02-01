#!/bin/bash

# ------------------------------------------------------------------
# Session 1: General 
# ------------------------------------------------------------------

# Version of this ISO
exam_version='3.3'

# Domain where to find the DNS RR TXT 'examdomains' with the domains allowed list, similar to:
# 	ddddd.com. 3600 IN TXT "examdomains=ddddd.com eeeee.edu fffff.org"
#	
# Each domain must have a DNS RR TXT 'examcfg' pointing to the exam configuration url
# where to get the session 2 institution data, similar to:
# 	ddddd.com. 3600 IN TXT "examcfg=https://exams.ddddd.com/local/exam_authorization/config.php"
#
# Leave blank for static configuration (do not query DNS records)
exam_domain_cfg="ddddd.com"

# Host IP that will be used for ping tests
ip_for_check="198.41.0.4"

# Host name thail will be used for DNS resolution tests
hostname_for_check="a.root-servers.net"

# ------------------------------------------------------------------
# Session 2: Institution data
# ------------------------------------------------------------------

# Required for static configuration

# Description of this ISO that will be shown in the screen backupground
exam_description="Moodle Exams"

# Institution name that will be shown in the screen backupground
institution_name="My Institution"

# Institution acronym that will be shown in the screen backupground
institution_acronym="MyIt"

# Institution contact email that will be shown in the screen backupground
contact_email="contact@my-institution.org"

# URL of the Institution Moodle Exam
exam_server_url="https://exam-myinstitution.org"

# List of pairs IPV4#port with extra IPV4 and TCP ports that must be open in the local firewall
# allowed_tcp_out_ipv4="192.168.1.1#443 192.168.1.2#80"
allowed_tcp_out_ipv4=""

# List of IPV6#port pars with extra IPV6 and TCP ports that must be open in the local firewall
# allowed_tcp_out_ipv6="2801:84:0:1001:192:168:1:3#443"
allowed_tcp_out_ipv6=""

# ------------------------------------------------------------------
# Session 3: Internal data
# ------------------------------------------------------------------

# Normally you don't need to change this

scripts_dir="/opt/exam_scripts"
user_home="/home/ubuntu"
cfg_json="/tmp/cfg.json"
wallpaper="${scripts_dir}/images/wallpaper.png"
log_file="/var/log/iso_exam.log"
message_file="${scripts_dir}/messages.txt"
select_desktop="select_domain.desktop"
user_domain_file="${user_home}/.exam_domain"
rulesv4="/etc/iptables/rules.v4"
rulesv6="/etc/iptables/rules.v6"
params_cfg=${scripts_dir}/exam_params.sh
select_domain_limit=10 # After this time (minutes) a new domain can no longer be selected
send_data_path="/local/exam_authorization/receive_data.php"
exam_domain=""
server_ip=""

source ${params_cfg}
