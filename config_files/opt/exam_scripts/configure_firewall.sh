#!/bin/bash

source ${BASH_SOURCE%/*}/exam_conf.sh
source ${scripts_dir}/functions.sh

log "Adjusting iptables"

if ! network_isup; then
    exit 1
fi

# Copy original iptable rules
cp ${rulesv4}.tpl $rulesv4
cp ${rulesv6}.tpl $rulesv6

# Remove all NFS related iptable rules
sed -i '/port .*\(111\|2049\)/d' $rulesv4

# Remove all NTP related iptable rules
sed -i "/port 123 /d" $rulesv4
sed -i "/port 123 /d" $rulesv6

# Remove all DNS related iptable rules
sed -i "/port 53 /d" $rulesv4
sed -i "/port 53 /d" $rulesv6

# Apply modified iptable rules
/sbin/iptables-restore < $rulesv4
/sbin/ip6tables-restore < $rulesv6

# Open DNS iptable rules
for ip in $(nmcli dev show | grep 'IP4.DNS' | sed 's/\s\s*/\t/g' | cut -f2); do
    log "Open IP4.DNS: ${ip}"
    iptables -A OUTPUT -d "${ip}" -p udp --dport 53 -j ACCEPT
    iptables -A INPUT  -s "${ip}" -p udp --sport 53 -j ACCEPT
    iptables -A OUTPUT -d "${ip}" -p tcp --dport 53 -j ACCEPT
done
for ip in $(nmcli dev show | grep 'IP6.DNS' | sed 's/\s\s*/\t/g' | cut -f2); do
    log "Open IP6.DNS: ${ip}"
    ip6tables -A OUTPUT -d "${ip}" -p udp --dport 53 -j ACCEPT
    ip6tables -A INPUT  -s "${ip}" -p udp --sport 53 -j ACCEPT
    ip6tables -A OUTPUT -d "${ip}" -p tcp --dport 53 -j ACCEPT
done
for ip in $(grep nameserver /etc/resolv.conf | grep -v 127.0 | cut -d' ' -f2); do
    log "Open DNS resolv.conf: ${ip}"
    iptables -A OUTPUT -d "${ip}" -p udp --dport 53 -j ACCEPT
    iptables -A INPUT  -s "${ip}" -p udp --sport 53 -j ACCEPT
    iptables -A OUTPUT -d "${ip}" -p tcp --dport 53 -j ACCEPT
done

# Open NTP iptable rules
ntp_server=$(grep -e '^NTP=' /etc/systemd/timesyncd.conf | cut -d'=' -f2)
for ip in $(dig -t A +short "${ntp_server}" | grep -E '^[0-9].*[0-9]$'); do
    log "Open IP4.NTP: ${ip}"
    iptables -A OUTPUT -d "${ip}" -p udp --dport 123 -j ACCEPT
    iptables -A INPUT  -s "${ip}" -p udp --sport 123 -j ACCEPT
done
for ip in $(dig -t AAAA +short "${ntp_server}" | grep -E '[A-Za-z0-9]+:[A-Za-z0-9:]+'); do
    log "Open IP6.NTP: ${ip}"
    ip6tables -A OUTPUT -d "${ip}" -p udp --dport 123 -j ACCEPT
    ip6tables -A INPUT  -s "${ip}" -p udp --sport 123 -j ACCEPT
done

# Open NFS iptable rules in the case of netboot just for the nfs server
if [ -f '/proc/cmdline' ] && grep -q 'nfsroot=' '/proc/cmdline' ; then
    nfs_server=$(cat /proc/cmdline | awk '/nfsroot/{print $1}' RS=" " FS=":" | cut -d'=' -f2)
    log "Open NFS: ${nfs_server}"
    iptables -A OUTPUT -p udp -d ${nfs_server} -m multiport --dport 111,2049 -j ACCEPT
    iptables -A INPUT  -p udp -s ${nfs_server} -m multiport --sport 111,2049 -j ACCEPT
    iptables -A OUTPUT -p tcp -d ${nfs_server} -m multiport --dport 111,2049 -j ACCEPT
    iptables -A INPUT  -p tcp -s ${nfs_server} -m multiport --sport 111,2049 -j ACCEPT
fi

# Add extra ipv4 rules to iptables
for entry in $allowed_tcp_out_ipv4 ; do
    log "Open IP4.TCP ${entry}"
    ip="${entry%#*}"
    port="${entry#*#}"
    iptables -A OUTPUT -d "${ip}" -p tcp --dport "${port}" -j ACCEPT
done

# Add extra ipv6 rules to the iptables
for entry in $allowed_tcp_out_ipv6 ; do
    log "Open IP6.TCP ${entry}"
    ip="${entry%#*}"
    port="${entry#*#}"
    ip6tables -A OUTPUT -d "${ip}" -p tcp --dport "${port}" -j ACCEPT
done

# Add server_host to the iptables (ipv4)
server_hostname=$(echo "${exam_server_url}" | cut -d'/' -f3)
if [[ "${exam_server_url}" =~ ^https ]] ; then
    port=443
else
    port=80
fi

ip=$(dig -t A +short "${server_hostname}" | grep -E '^[0-9].*[0-9]$' | tail -n1)
if [ -n "${ip}" ] ; then
    log "Open IP4.TCP ${ip} ${port}"
    iptables -A OUTPUT -d "${ip}" -p tcp --dport ${port} -j ACCEPT
fi

ip6=$(dig -t AAAA +short "${server_hostname}" | grep -E '[A-Za-z0-9]+:[A-Za-z0-9:]+' | tail -n1)
if [ -n "${ip6}" ] ; then
    log "Open IP6.TCP ${ip} ${port}"
    ip6tables -A OUTPUT -d "${ip6}" -p tcp --dport ${port} -j ACCEPT
fi

iptab=$(iptables --list)
log "$iptab"

exit 0
