#!/bin/bash
set -xe

cat > /etc/rsyslog.d/30-iptables.conf <<'RSY'
:msg, contains, "SYN " /var/log/otlab/iptables.log
& stop
RSY

cat > /etc/rsyslog.d/31-kern.conf <<'RSY'
kern.* /var/log/otlab/kern.log
RSY

/usr/sbin/rsyslogd

iptables -A INPUT -p tcp --syn -j LOG --log-prefix "SYN " --log-level 4

nohup tcpdump -i any -w /var/log/otlab/scan-%Y%m%d-%H%M%S.pcap -G 300 -W 12 not port 22 >/dev/null 2>&1 &

/usr/sbin/sshd
apache2ctl start

tail -f /dev/null