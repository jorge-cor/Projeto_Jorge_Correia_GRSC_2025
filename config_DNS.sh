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
nmcli
while [ $opcao -ne 7 ]; do

echo -e "${verde}------------------ Menu Principal ------------------${reset}"
echo "1. Definir IP estatico"
echo "2. Atualizar sistema e instalar servidor DHCP"
echo "3. Configurar DHCP"
echo "4. Correr tudo menos passagem Gateway"
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