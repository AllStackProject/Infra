#!/bin/bash

set -e

VIP="172.16.2.110"
NET_IF="ens192"
NODE_IP=$(hostname -I | awk '{print $1}')
PRIORITY=100
STATE="MASTER"

echo "node IP : $NODE_IP"
echo "VIP: $VIP"
echo "Network Interface: $NET_IF"
sleep 2

echo "haproxy / keepalived deleting.."
sudo systemctl stop haproxy || true

sudo systemctl stop keepalived || true
sudo apt remove --purge -y haproxy keepalived || true
sudo rm -rf /etc/haproxy /etc/keepalived /var/lib/haproxy /var/log/haproxy* /run/haproxy

sudo systemctl daemon-reload

echo "haproxy / keepalived download.."
sudo apt update -y
sudo apt install -y haproxy keepalived

echo "HAProxy cfg file configure.."

sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<'EOF'
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

backend patroni_nodes_writer
    mode tcp
    option httpchk
    http-check send meth GET uri /primary ver HTTP/1.1 hdr Host localhost
    http-check expect status 200

    server db1 172.16.2.111:5432 check port 8008
    server db2 172.16.2.112:5432 check port 8008
    server db3 172.16.2.113:5432 check port 8008

frontend pg_writer
    bind *:5000
    mode tcp
    default_backend patroni_nodes_writer
EOF

echo "Keepalived file make "

sudo tee /etc/keepalived/keepalived.conf > /dev/null <<'EOF'
vrrp_instance VI_1 {
    state MASTER
    interface ens192
    virtual_router_id 51
    priority 100
    advert_int 1

    authentication {
        auth_type PASS
        auth_pass 1111
    }

    virtual_ipaddress {
        172.16.2.110/24
    }

    track_script {
        chk_haproxy
    }
}

vrrp_script chk_haproxy {
    script "pidof haproxy"
    interval 2
    weight 2
}
EOF

echo " service start "

sudo systemctl daemon-reload
sudo systemctl enable haproxy keepalived
sudo systemctl restart haproxy
sudo systemctl restart keepalived

echo "status check "
sudo systemctl status haproxy --no-pager
sudo systemctl status keepalived --no-pager
