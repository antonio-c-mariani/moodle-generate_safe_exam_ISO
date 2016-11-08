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
-A INPUT  -p ipv6-icmp -j ACCEPT
-A OUTPUT -p ipv6-icmp -j ACCEPT

# Accept DNS
-A INPUT  -p udp --sport 53 -j ACCEPT
-A OUTPUT -p udp --dport 53 -j ACCEPT

# Accept NTP
-A INPUT  -p udp --sport 123 -j ACCEPT
-A OUTPUT -p udp --dport 123 -j ACCEPT

# Log everything that is denied
# -A INPUT -j LOG --log-prefix "IPv6 - denied INPUT: "
# -A OUTPUT -j LOG --log-prefix "IPv6 - denied OUTPUT: "

COMMIT
