# Ferramentas Servidor CentOS / Red Hat

[![Shell Script](https://img.shields.io/badge/Shell_Script-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![CentOS](https://img.shields.io/badge/CentOS-9%20%7C%2010-262577?logo=centos&logoColor=white)](https://www.centos.org/)
[![Red Hat](https://img.shields.io/badge/Red%20Hat-Enterprise%20Linux-CC0000?logo=redhat&logoColor=white)](https://www.redhat.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-orange)](#)

Este repositório contém um conjunto de scripts em Shell (sh) para automação e configuração de serviços em sistemas Linux (focado em CentOS/RHEL).

## 📂 Estrutura do Projeto

O projeto está organizado com um menu principal que chama módulos específicos localizados na pasta `modulos/`.

```
.
├── main.sh                # Script principal (Menu)
└── modulos/               # Pasta com os scripts de configuração
    ├── config_dhcp.sh
    ├── config_DHCP_kea.sh
    ├── config_DNS_blind.sh
    ├── config_SSH_FTP.sh
    └── gestao_de_discos.sh
```

## 🛠️ Funcionalidades
### 1. DHCP (ISC & Kea)
Definição de IPs estáticos.

Instalação e configuração de servidores DHCP.

Ativação de Gateway (IP Forwarding) para sistemas com duas placas de rede.

Gestão de interfaces.

### 2. DNS (BIND9)
Instalação do servidor DNS (Bind).

Configuração de zonas e entradas DNS.

Ativação automática do serviço.

### 3. SSH & FTP
Configuração de segurança SSH.

Implementação de autenticação via chave RSA (Passwordless).

Bloqueio de utilizadores sem chave para maior segurança.

Configuração de servidor FTP (VSFTPD) e gestão de utilizadores.

### 4. Gestão de Discos e Serviços
Listagem de discos e partições.

Integração com MariaDB (verificação de bases de dados).

Verificação de módulos PHP.

Gestão de RAID e montagem/desmontagem de discos.

## 🚀 Como Utilizar
### 1. Clonar o repositório:

```bash
git clone https://github.com/jorge-cor/Ferramentas_CentOS_-_Red_Hat/
cd Ferramentas_CentOS_-_Red_Hat
```
### 2. Dar permissões de execução:

```bash
chmod +x main.sh modulos/*.sh
```
### 3. Executar o script:

```bash
./main.sh
```
## ⚠️ Requisitos
Sistema Operativo: CentOS ou RHEL.

Acesso de Root (Sudo).

Conexão à internet para instalação de pacotes (yum/dnf).

Desenvolvido para administração de sistemas.
