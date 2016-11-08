*filter
# Default is to block everything
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]

# Accept local trafic traffic (loopback)
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT

# Accept previously established connections
-A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Accept icmp (ping)
-A INPUT  -p icmp -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT

# Accept DNS
-A INPUT  -p udp --sport 53 -j ACCEPT
-A OUTPUT -p udp --dport 53 -j ACCEPT

# Accept NTP
-A INPUT  -p udp --sport 123 -j ACCEPT
-A OUTPUT -p udp --dport 123 -j ACCEPT

# Accept NFS (remote boot)
-A INPUT  -p udp -m multiport --sport 111,2049 -j ACCEPT
-A OUTPUT -p udp -m multiport --dport 111,2049 -j ACCEPT
-A INPUT  -p tcp -m multiport --sport 111,2049 -j ACCEPT
-A OUTPUT -p tcp -m multiport --dport 111,2049 -j ACCEPT

# Log everything that is denied
# -A INPUT -j LOG --log-prefix "IPv4 - denied INPUT: "
# -A OUTPUT -j LOG --log-prefix "IPv4 - denied OUTPUT: "

COMMIT
