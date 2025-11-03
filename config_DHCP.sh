#! /bin/bash
inter=""
ipad=""
gat=""
dns=""
opcao=0
reset='\e[0m'
azul='\e[34m'
verde='\e[32m'
amarelo='\e[33m'
vermelho='\e[31m'
CONFIG_FILE=""
HW_ADDR=""
IP_ADDR=""
HOSTNAME=""
while [ $opcao -ne 7 ]; do

nmcli
echo -e "${verde}------------------ Menu Principal ------------------${reset}"
echo "1. Definir IP estatico"
echo "2. Atualizar sistema e instalar servidor DHCP"
echo "3. Configurar DHCP"
echo "4. Defenir uma reserva de IP"
echo -e "5. Ativar Gateaway ${amarelo}(necessário ter duas placas ligadas)${reset}"
echo "6. Enable Interfaces"
echo "7. Sair"
echo -e "${verde}-----------------------------------------------------${reset}"

printf "Escolha uma opção (1-7): "
read opcao

case $opcao in
1)
echo -e "${azul}A executar a Opção 1...${reset}"
echo "Coloque a interface :"
read inter
echo "Introduza o IP da maquina no formato 192.168.1.1/24 "
read ipad
echo "Introduza o IP do Gateway no formato 192.168.1.254 "
read gat
echo "Introduza o IP do DNS Server no formato 192.168.1.254 "
read dns
sudo nmcli connection up $inter
sudo systemctl restart NetworkManager
sudo nmcli connection modify $inter ipv4.address $ipad
sudo nmcli connection modify $inter ipv4.method manual
sudo nmcli connection down $inter
sudo nmcli connection up $inter
sudo nmcli connection modify $inter ipv4.gateway $gat
sudo nmcli connection modify $inter ipv4.dns $dns
;;
2)
echo -e "${azul}A executar a Opção 2...${reset}"
sudo yum update -y
sudo dnf update -y
sudo dnf install kea -y
sudo firewall-cmd --add-service=dhcp --permanent
sudo firewall-cmd --reload
;;
3)
echo -e "${azul}A executar a Opção 3...${reset}"
nmcli
echo "Coloque a interface Ex "ens192":"
read inter
echo "Introduza o primeiro IP do Range para o DHCP no formato 192.168.1.10"
read dhcp_primeiro
echo "Introduza o ultimo IP do Range para o DHCP no formato 192.168.1.100"
read dhcp_ultimo
echo "Introduza o ID da rede no formato 192.168.1.0/24"
read network
echo "Introduza o IP do Gateway no formato 192.168.1.254 "
read gat
echo "Introduza o IP do DNS Server no formato 192.168.1.254 "
read dns
echo "Introduza o mac do DNS Server no formato FF:FF:FF:FF:FF:FF"
read mac

#/etc/dhcp/dhcpd.conf
sudo touch /etc/kea/kea-dhcp4.conf
sudo tee /etc/kea/kea-dhcp4.conf < /dev/null
sudo tee /etc/kea/kea-dhcp4.conf <<EOF
{
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "$inter" ]
    },
    "subnet4": [
        {
            "id": 1,
            "subnet": "$network",
            "pools": [
                { "pool": "$dhcp_primeiro - $dhcp_ultimo" }
            ],
            "option-data": [
                { "name": "routers", "data": "$gat" },
                { "name": "domain-name-servers", "data": "$dns, 8.8.8.8" }
            ],
            "reservations": [
                {
                    "hw-address": "$mac",
                    "ip-address": "$dns",
                    "hostname": "servidor-DNS"
                }
            ]
        } 
    ]
}
}
EOF
echo -e "\n${verde}A validar a Sintaxe JSON...${rese}"
sudo kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
echo -e "\n${verde}Prima ENTER para continuar...${rese}"
read PAUSA
sudo systemctl enable kea-dhcp4
sudo systemctl start kea-dhcp4
sudo systemctl status kea-dhcp4
;;
4)
echo -e "${azul}A executar a Opção 4...${reset}"
CONFIG_FILE="/etc/kea/kea-dhcp4.conf"
echo "Introduza o IP a reservar formato 192.168.1.254 "
read IP_ADDR
echo "Introduza o mac da placa a reservar formato FF:FF:FF:FF:FF:FF"
read HW_ADDR
echo "Introduza o Nome descritivo da maquina"
read HOSTNAME

# Construir o objeto JSON da nova reserva (com ou sem hostname)
if [ -n "$HOSTNAME" ]; then
    # Com hostname
    NEW_RESERVATION=$(jq -n \
        --arg mac "$HW_ADDR" \
        --arg ip "$IP_ADDR" \
        --arg host "$HOSTNAME" \
        '{ "hw-address": $mac, "ip-address": $ip, "hostname": $host }')
else
    # Sem hostname
    NEW_RESERVATION=$(jq -n \
        --arg mac "$HW_ADDR" \
        --arg ip "$IP_ADDR" \
        '{ "hw-address": $mac, "ip-address": $ip }')
fi

TEMP_FILE=$(mktemp)
JQ_FILTER='.Dhcp4.subnet4[0].reservations += [$new_res]'
if ! sudo jq --argjson new_res "$NEW_RESERVATION" "$JQ_FILTER" "$CONFIG_FILE" > "$TEMP_FILE"; then
    echo "Erro: Falha ao processar o ficheiro JSON com jq. Verifique se a estrutura está limpa."
    rm -f "$TEMP_FILE"
    exit 1
fi

sudo mv "$TEMP_FILE" "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "Sucesso: Reserva para $HW_ADDR ($IP_ADDR) adicionada a '$CONFIG_FILE'."
else
    echo "Erro: Falha ao mover o ficheiro atualizado para o destino."
    exit 1
fi
sudo chown kea:kea /etc/kea/kea-dhcp4.conf
sudo chmod 640 /etc/kea/kea-dhcp4.conf
sudo systemctl restart kea-dhcp4
sudo systemctl status kea-dhcp4
;;
5)
echo -e "${azul}A executar a Opção 5...${reset}"
nmcli conn show --active
# 1. Ativar o encaminhamento de IP de forma permanente
sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
echo -e "Verificar se está ativo (deve retornar 1) \n ${verde}Prima ENTER para continuar...${rese}"
read PAUSA
cat /proc/sys/net/ipv4/ip_forward
sudo firewall-cmd --zone=public --add-masquerade --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --query-masquerade
;;
6)
echo -e "${azul}A executar a Opção 6...${reset}"
echo "nome da interface a ativar"
read inter
sudo touch /etc/sysconfig/network-scripts/ifcfg-$inter
sudo tee /etc/sysconfig/network-scripts/ifcfg-$inter <<EOF
TYPE=Ethernet
BOOTPROTO=dhcp
IPV4_FAILURE_FATAL=no
DEVICE=$inter
NAME=$inter
ONBOOT=yes
EOF
sudo systemctl restart NetworkManager
nmcli
;;
7)
echo -e "${vermelho}A sair do menu. Até breve!${reset}"
;;
*)
echo "Opção inválida. Por favor, escolha um número entre 1 e 7."
opcao=0
;;
esac
echo "" 
done