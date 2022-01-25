# !/bin/bash

# reference: https://techblog.ap-com.co.jp/entry/2019/06/28/100439

set -eux

ip netns add host1
ip netns add router
ip netns add host2

ip link add name host1-veth1 type veth peer name router-veth1
ip link add name router-veth2 type veth peer name host2-veth1

ip link set host1-veth1 netns host1
ip link set router-veth1 netns router
ip link set router-veth2 netns router
ip link set host2-veth1 netns host2

ip netns exec host1 ip addr add 10.0.0.1/24 dev host1-veth1
ip netns exec router ip addr add 10.0.0.254/24 dev router-veth1
ip netns exec router ip addr add 10.0.1.254/24 dev router-veth2
ip netns exec host2 ip addr add 10.0.1.1/24 dev host2-veth1

ip netns exec host1 ip link set host1-veth1 up
ip netns exec router ip link set router-veth1 up
ip netns exec router ip link set router-veth2 up
ip netns exec host2 ip link set host2-veth1 up
ip netns exec host1 ip link set lo up
ip netns exec router ip link set lo up
ip netns exec host2 ip link set lo up

ip netns exec host1 ip route add 0.0.0.0/0 via 10.0.0.254
ip netns exec host2 ip route add 0.0.0.0/0 via 10.0.1.254
ip netns exec router sysctl -w net.ipv4.ip_forward=1

# drop RST
ip netns exec host1 iptables -A OUTPUT -p tcp --tcp-flags RST RST -j DROP
ip netns exec host2 iptables -A OUTPUT -p tcp --tcp-flags RST RST -j DROP

# turn off checksum offloading
ip netns exec host2 ethtool -K host2-veth1 tx off
ip netns exec host1 ethtool -K host1-veth1 tx off