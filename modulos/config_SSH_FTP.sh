#!/bin/bash

opcao=0
reset='\e[0m'
azul='\e[34m'
verde='\e[32m'
amarelo='\e[33m'
vermelho='\e[31m'
inter=""
ipad=""
gat=""
dns=""
porta=""
portaf=""
tentativas=""
sessoes=""
timec=""
times=""
passmin=""
passmax=""
user=""
passe=""
while [ $opcao -ne 7 ]; do

echo -e "${verde}------------------ Menu Principal ------------------${reset}"
echo "1. Definir IP estatico"
echo "2. Configurar SSH"
echo "3. Criação chave RSA para SSh"
echo "4. Bloquear utilizadores sem chave RSA"
echo -e "5. Configurar FTP${amarelo} (VSFTPD) ${reset}"
echo "6. Criar utilizador para FTP"
echo "7. Sair"
echo -e "${verde}-----------------------------------------------------${reset}"

printf "Escolha uma opção (1-7): "
read opcao

case $opcao in
1)

# CONFIGURAÇÃO DE REDE COM NMCLI 
echo ""
echo -e "${azul}--- 1. CONFIGURAÇÃO DE REDE ---${reset}"
nmcli 
printf "Coloque a interface (ex: eth0):\n"
read inter
printf "Introduza o IP da maquina (ex: 192.168.1.10/24):\n"
read ipad
printf "Introduza o IP do Gateway (ex: 192.168.1.1):\n"
read gat
printf "Introduza o IP do DNS Server (ex: 8.8.8.8): \n"
read dns
# Aplicação da Configuração NMCLI
echo -e "${verde}A aplicar a configuração de rede...${reset}"
sudo nmcli connection modify "$inter" ipv4.address "$ipad"
sudo nmcli connection modify "$inter" ipv4.method manual
sudo nmcli connection modify "$inter" ipv4.gateway "$gat"
sudo nmcli connection modify "$inter" ipv4.dns "$dns"
sudo nmcli connection down "$inter"
sudo nmcli connection up "$inter"
;;
2)
# CONFIGURAÇÃO SSH 
echo ""
echo -e "${azul}--- 2. CONFIGURAÇÃO SSH ---${reset}"
cd /etc/ssh || { echo "${vermelho}Erro: Não foi possível mudar para /etc/ssh${reset}"; exit 1; }
printf "Introduza a porta SSH (porta 22 ou acima de 46998): \n"
read porta
printf "Introduza o máximo de tentativas de autenticação: \n"
read tentativas
printf "Introduza o número máximo de sessões: \n"
read sessoes
echo -e "${verde}A configurar o sshd_config...${reset}"
# Porta
sudo sed -i -r "/^#?Port/c\Port $porta" sshd_config
# MaxAuthTries
sudo sed -i -r "/^#?MaxAuthTries/c\MaxAuthTries $tentativas" sshd_config
# MaxSessions
sudo sed -i -r "/^#?MaxSessions/c\MaxSessions $sessoes" sshd_config
# Outras Configurações
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' sshd_config
#sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' sshd_config
sudo sed -i 's/^#PermitEmptyPassword no/PermitEmptyPassword no/' sshd_config
sudo sed -i 's/^#PubKeyAuthentication yes/PubKeyAuthentication yes/' sshd_config
# Iniciar o serviço SSH
echo -e "${verde}A iniciar o serviço sshd...${reset}"
sudo yum -y update
sudo systemctl restart sshd
sudo systemctl status sshd | head -n 3
# CONFIGURAÇÃO FIREWALL SSH
echo -e "${azul}--- 3. CONFIGURAÇÃO FIREWALL SSH ---${reset}"
sudo firewall-cmd --zone=public --add-port="$porta"/tcp --permanent
sudo firewall-cmd --zone=public --add-port="$porta"/udp --permanent
sudo firewall-cmd --reload
sudo systemctl restart NetworkManager
;;
3)
# CRIAÇÃO DE CHAVES SSH 
echo -e "${azul}--- 4. CRIAÇÃO DE CHAVES SSH ---${reset}"
echo -e "${verde}A gerar chaves RSA (prima Enter para os defaults)...${reset}"
# Criação das chaves
ssh-keygen -t rsa
mkdir -p ~/.ssh
chmod 700 ~/.ssh 
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys 
# Adicionar a chave pública ao authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo -e "${verde}Chave pública copiada para authorized_keys.${reset}"
;;
4)
sudo sed -i -r "s/^#?PubkeyAuthentication no/PubkeyAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i -r "s/^#?PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i "\$a\ChallengeResponseAuthentication no" /etc/ssh/sshd_config
sudo sed -i -r "s/^#?UsePAM no/UsePAM no/" /etc/ssh/sshd_config
sudo systemctl restart sshd
;;
5)
# CONFIGURAÇÃO VSFTPD 
printf "Introduza a porta FTP (porta 21 ou acima de 46999): \n"
read portaf
printf "Timeout em segundos para a sessão (ex: 5 minutos = 300): \n"
read times
printf "Timeout em segundos para transferências de dados(ex: 2 minutos = 120): \n"
read timec
printf "Introduza a porta FTP passiva inicial(exemplo 40000)\n"
read passmin
printf "Introduza a porta FTP passiva Final(exemplo 40100)total maximo de ligações:\n"
read passmax
echo ""
echo -e "${azul}--- 5. CONFIGURAÇÃO VSFTPD ---${reset}"
echo -e "${verde}A instalar o vsftpd...${reset}"
sudo dnf -y update
sudo dnf install vsftpd -y
#/etc/vsftpd/vsftpd.conf"
sudo sed -i 's/^listen=NO/listen=YES/' /etc/vsftpd/vsftpd.conf
sudo sed -i 's/^listen_ipv6=YES/listen_ipv6=NO/' /etc/vsftpd/vsftpd.conf
sudo sed -i 's/^#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd/vsftpd.conf
sudo sed -i 's/^#chroot_list_enable=YES/chroot_list_enable=YES/' /etc/vsftpd/vsftpd.conf
sudo sed -i '/^#chroot_list_file/ s/^#//' /etc/vsftpd/vsftpd.conf
sudo sed -i -r "s/^#?idle_session_timeout=.*/idle_session_timeout=$times/" /etc/vsftpd/vsftpd.conf
sudo sed -i -r "s/^#?data_connection_timeout=.*/data_connection_timeout=$timec/" /etc/vsftpd/vsftpd.conf
sudo sed -i "\$a\listen_port=$portaf" /etc/vsftpd/vsftpd.conf
sudo sed -i "\$a\pasv_enable=YES" /etc/vsftpd/vsftpd.conf
sudo sed -i "\$a\pasv_min_port=$passmin" /etc/vsftpd/vsftpd.conf
sudo sed -i "\$a\pasv_max_port=$passmax" /etc/vsftpd/vsftpd.conf
# Iniciar o serviço vsftpd
sudo systemctl enable vsftpd
sudo systemctl start vsftpd
sudo systemctl status vsftpd | head -n 3

#  CONFIGURAÇÃO FIREWALL VSFTPD 
echo -e "${azul}--- 6. CONFIGURAÇÃO FIREWALL VSFTPD ---${reset}"
sudo firewall-cmd --zone=public --add-port=$passmin-$passmax/tcp --permanent
sudo firewall-cmd --zone=public --add-service=ftp --permanent
sudo firewall-cmd --zone=public --add-port=$portaf/tcp --permanent
sudo firewall-cmd --reload
sudo setsebool -P allow_ftp_home_dirs on
echo -e "${verde}VSFTPD e Firewall configurados. FIM do Script.${reset}"
;;
6)
printf "Introduza o utilizador a criar: \n"
read user
sudo useradd -m "$user"
if [ $? -eq 0 ]; then
    printf "\nUtilizador '$user' criado com sucesso. Agora defina a palavra-passe/senha.\n"
    sudo passwd "$user"
    sudo mkdir /home/$user/Downloads
    sudo touch /home/$user/Downloads/apenas_leitura
    sudo mkdir /home/$user/Uploads
    sudo chown $user:$user /home/$user/Downloads
    sudo chmod u-w /home/$user/Downloads
    sudo chown $user:$user /home/$user/Uploads
    echo "$user" | sudo tee -a /etc/vsftpd/chroot_list
    sudo systemctl restart vsftpd
else
    echo "ERRO: Falha ao criar o utilizador '$user'.\n"
fi

;;
7)
echo -e "${vermelho}A sair do menu. Até breve!${reset}"
;;
*)
echo "Opção inválida. Por favor, escolha um número entre 1 e 7."
opcao="0"
;;
esac
echo "" 
done