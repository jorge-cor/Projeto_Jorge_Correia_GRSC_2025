#!/bin/bash

# Cores para o terminal
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AZUL='\033[0;34m'
NC='\033[0m' # Sem Cor

# Função para verificar se o script corre como root
if [[ $EUID -ne 0 ]]; then
   echo -e "${VERMELHO}Este script precisa de ser executado com sudo/root.${NC}"
   exit 1
fi

while true; do
    echo -e "${AZUL}==========================================${NC}"
    echo -e "          MENU DE GESTÃO TÉCNICA"
    echo -e "${AZUL}==========================================${NC}"
    echo "1) Listar Discos (lsblk)"
    echo "2) MariaDB: Listar Bases de Dados"
    echo "3) PHP: Verificar Versão e Módulos"
    echo "4) Desativar/Desmontar Disco"
    echo "5) Ativar Disco e Remontar em RAID"
    echo "6) Sair"
    echo -ne "${VERDE}Escolha uma opção: ${NC}"
    read opt

    case $opt in
        1)
            echo -e "\n--- Estrutura de Blocos ---"
            lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
            ;;
        2)
            echo -e "\n--- Bases de Dados (MariaDB) ---"
            mysql -u root -p -e "SHOW DATABASES;"
            ;;
        3)
            echo -e "\n--- Configuração PHP ---"
            php -v | head -n 1
            echo "Módulos ativos:"
            php -m | column
            ;;
        4)
	    echo -e "\n--- Estrutura de Blocos ---"
            lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
	    echo -ne "Introduza o dispositivo RAID (ex: /dev/md0): "
            read raid
            echo -ne "Introduza o disco a remover (ex: /dev/nvme0n5): "
            read disco
            echo "A marcar $disco como falhado em $raid..."
            mdadm --manage $raid --fail $disco
            sleep 1
            echo "A remover $disco da RAID..."
            mdadm --manage $raid --remove $disco
            echo -e "${VERDE}Concluído.${NC}"
            ;;
        5)
	    echo -e "\n--- Estrutura de Blocos ---"
            lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
            echo -ne "Introduza o disco (ex: /dev/sdb1): "
            read disco
            echo -ne "Introduza o dispositivo RAID (ex: /dev/md0): "
            read raid
            echo "A adicionar $disco à RAID $raid..."
            mdadm --manage $raid --add $disco
            mount $raid && echo -e "${VERDE}RAID Remontada!${NC}"
            ;;
        6)
            echo "A sair..."
            break
            ;;
        *)
            echo -e "${VERMELHO}Opção inválida!${NC}"
            ;;
    esac
    echo -e "\nPrima Enter para continuar..."
    read
    clear
done
