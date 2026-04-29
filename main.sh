#!/bin/sh

amarelo='\033[1;33m'
azul='\033[1;34m'
reset='\033[0m'

# Caminho para a pasta dos módulos
MODULOS_DIR="./modulos"

while true; do
    clear
    echo -e "${azul}=========================================="
    echo -e "       GESTOR DE CONFIGURAÇÃO LINUX       "
    echo -e "==========================================${reset}"
    echo "1. Configurar DHCP (ISC)"
    echo "2. Configurar DHCP (Kea)"
    echo "3. Configurar DNS (Bind9)"
    echo "4. Configurar SSH & FTP"
    echo "5. Gestão de Discos e Serviços"
    echo "0. Sair"
    echo -ne "\nEscolha uma opção: "
    read opcao

    case $opcao in
        1)
            sh "$MODULOS_DIR/config_dhcp.sh"
            ;;
        2)
            sh "$MODULOS_DIR/config_DHCP_kea.sh"
            ;;
        3)
            sh "$MODULOS_DIR/config_DNS_blind.sh"
            ;;
        4)
            sh "$MODULOS_DIR/config_SSH_FTP.sh"
            ;;
        5)
            sh "$MODULOS_DIR/gestao_de_discos.sh"
            ;;
        0)
            echo "A sair..."
            exit 0
            ;;
        *)
            echo -e "${amarelo}Opção inválida! Pressione Enter para continuar.${reset}"
            read
            ;;
    esac

    echo -e "\n${azul}Tarefa concluída. Pressione Enter para voltar ao menu.${reset}"
    read
done