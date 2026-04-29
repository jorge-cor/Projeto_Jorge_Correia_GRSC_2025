#! /bin/bash
nmcli
nmcli conn show --active
# 1. Ativar o encaminhamento de IP de forma permanente
sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
# 2. Verificar se está ativo (deve retornar "1")
cat /proc/sys/net/ipv4/ip_forward
sudo firewall-cmd --zone=public --add-masquerade --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --query-masquerade