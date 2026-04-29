#! /bin/bash
inter=""
ipad=""
gat=""
dns=""
acl=""
netw=""
mask=""
oct1=""
oct2=""
oct3=""
oct4=""
ioct1=""
ioct2=""
ioct3=""
ioct4=""
domin=""
domi1=""
domi2=""
opcao=0
soct=""
poct=""
reset='\e[0m'
azul='\e[34m'
verde='\e[32m'
amarelo='\e[33m'
vermelho='\e[31m'
nmcli
while [ $opcao -ne 6 ]; do

echo -e "${verde}------------------ Menu Principal ------------------${reset}"
echo "1. Definir IP estatico"
echo "2. Atualizar sistema e instalar servidor DNS(BLIND)"
echo "3. Configurar DNS"
echo "4. Ablitar o serviço"
echo "5. Defenir entradas no DNS server(bind)"
echo "6. Sair"
echo -e "${verde}-----------------------------------------------------${reset}"

printf "Escolha uma opção (1-6): "
read opcao

case $opcao in
1)
echo -e "${azul}A executar a Opção 1...${reset}"
nmcli connection show
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
sudo nmcli connection modify $inter ipv4.gateway $gat
sudo nmcli connection modify $inter ipv4.dns $dns
sudo nmcli connection down $inter
sudo nmcli connection up $inter
;;
2)
echo -e "${azul}A executar a Opção 2...${reset}"
sudo yum update -y
sudo dnf update -y
sudo dnf install bind bind-utils -y
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload
;;
3)
echo -e "${azul}A executar a Opção 3...${reset}"
echo "Criar acl ex: (internal-network)"
read acl
echo "Introduza a network da rede no formato 192.168.1.0 "
read netw
echo "Introduza a Mascara da rede no formato de 8 a 32 "
read mask
echo "Introduza o Nome de dominio no formato de exemplo.pt "
read domin
echo "Introduza o IP da maquina no formato 192.168.1.1 "
read ipad
nmcli connection show
echo "Coloque a interface :"
read inter
IFS='.' read -r ioct1 ioct2 ioct3 ioct4 <<< "$ipad"
IFS='.' read -r domi1 domi2 <<< "$domin"
IFS='.' read -r oct1 oct2 oct3 oct4 <<< "$netw"
if [[ ! "$mask" =~ ^[0-9]+$ ]]; then
    echo "Erro: O prefixo '$mask' não é um número."
    
elif [ "$mask" -le 16 ]; then
    # "se ate 16"
    echo "LOG: Prefixo ($mask) é <= 16."
    soct="${ioct4}.${ioct3}.${ioct2}"
    poct="${ioct1}"

elif [ "$mask" -le 24 ]; then
    # "se ate 24" (implica que é > 16)
    echo "LOG: Prefixo ($mask) é > 16 e <= 24."
    soct="${ioct4}.${ioct3}"
    poct="${ioct2}.${ioct1}"

elif [ "$mask" -le 32 ]; then
    # "se ate 32" (implica que é > 24)
    echo "LOG: Prefixo ($mask) é > 24 e <= 32."
    soct="${ioct4}"
    poct="${ioct3}.${ioct2}.${ioct1}"

else
    echo "Erro: Prefixo '$mask' é inválido (maior que 32)."
    soct="INVALIDO"
fi
echo -e "\n${verde}Prima ENTER para continuar...${rese}"
read PAUSA
sudo touch /etc/named.conf
sudo tee /etc/named.conf < /dev/null
sudo tee /etc/named.conf <<EOF
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
acl $acl{
        $netw/$mask;
};
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { localhost; $acl; };
        allow-transfer  { localhost; };
        /*
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
         - If you are building a RECURSIVE (caching) DNS server, you need to enable
           recursion.
         - If your recursive DNS server has a public IP address, you MUST enable access
           control to limit queries to your legitimate users. Failing to do so will
           cause your server to become part of large scale DNS amplification
           attacks. Implementing BCP38 within your network would greatly
           reduce such attack surface
        */
        forwarders {
        8.8.8.8;    // Google DNS
        1.1.1.1;    // Cloudflare
        };
        forward only;
        recursion yes;
        dnssec-validation yes;
        managed-keys-directory "/var/named/dynamic";
        geoip-directory "/usr/share/GeoIP";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
        /* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
        include "/etc/crypto-policies/back-ends/bind.config";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "$domi1" IN {
        type master;
        file "$domin.db";
        allow-update { none; };
};
zone "$poct.in-addr.arpa" IN {
        type master;
        file "$poct.db";
        allow-update {none; };
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF
sudo chown root:named /etc/named.conf
sudo chmod 640 /etc/named.conf
sudo touch /var/named/$domin.db
sudo tee /var/named/$domin.db < /dev/null
sudo touch /var/named/$ioct3.$ioct2.$ioct1.db
sudo tee /var/named/$ioct3.$ioct2.$ioct1.db < /dev/null
sudo tee /var/named/$domin.db <<EOF
\\$TTL 86400 ; Tempo de vida padrão (1 dia)
@   IN  SOA     ns.$domin. root.$domin. (
            2024102401  ; Serial (data de hoje + versão)
            3600        ; Refresh (1 hora)
            1800        ; Retry (30 minutos)
            604800      ; Expire (1 semana)
            86400       ; Minimum TTL (1 dia)
)

; Servidores de Nomes (NS)
@   IN  NS      ns.$domin.

; Registos de Endereço (A)
ns         IN  A       $ipad  ; O próprio servidor DNS

EOF

sudo tee /var/named/$poct.db <<EOF
\\$TTL 86400 ; 
@   IN  SOA   ns.$domin. root.$domin. (
        2025110301 ; Serial 
        3H         ; Refresh
        15M        ; Retry
        1W         ; Expire
        1D )       ; Minimum TTL


@   IN  NS      ns.$domin.

$soct  IN  PTR     ns.$domin.

EOF
sudo chown -R named:named /var/named/
sudo nmcli con mod $inter ipv4.dns 127.0.0.1
sudo nmcli con mod $inter ipv4.ignore-auto-dns yes
sudo nmcli con down $inter
sudo nmcli con up $inter
;;
4)
echo -e "${azul}A executar a Opção 4...${reset}"
sudo systemctl start named
sudo systemctl enable named
echo -e "${amarelo}Status do DNS server(BIND)...${reset}"
sudo systemctl status named
echo -e "\n${verde}Prima ENTER para continuar...${rese}"
read PAUSA
;;
5)
echo -e "${azul}A executar a Opção 5...${reset}"
echo ""
;;
6)
echo -e "${vermelho}A sair do menu. Até breve!${reset}"
;;
*)
echo "Opção inválida. Por favor, escolha um número entre 1 e 6."
opcao=0
;;
esac
echo "" 
done