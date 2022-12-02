#!/bin/bash
# Script de instalaçao do serviço de monitoria - cliente.
# Pre-requisitos - cliente

# instalar o iostat, rsync
apt-get install sysstat -y
apt-get install rsync -y

# Instalar tarefa na crontab para gerar os arquivos
if [ `crontab -l |grep coleta.sh` -eq '']; then
crontab -l | { cat; echo "# Serviço de monitoraçao, gera os arquivos - Cliente"; echo "* * * * * bash /usr/sbin/monitoria/coleta.sh"; } | crontab -
else
echo '======================================================'
echo ''
echo 'CRONTAB JA ESTA CONFIGURADA'
echo ''
echo '======================================================'
fi

#Configurar o rsync (/etc/rsyncd.conf e /etc/rsyncd.passwd)
cp ./rsyncd.conf /etc/rsyncd.conf
echo monitor:senha > /etc/rsyncd.passwd
chmod 0640 /etc/rsyncd.conf
chmod 0600 /etc/rsyncd.passwd

# habilitar rsync e iniciar
systemctl enable rsync; systemctl restart rsync

# criar usuario da monitoraçao
useradd -c "Usuario de monitoraçao" monitor

# criar diretorio do script no /usr/sbin/monitoria
mkdir -p -p /usr/sbin/monitoria

# Enviar o script para o diretorio do script e atribuir a permissão de execuçao
cp ./coleta.sh /usr/sbin/monitoria/coleta.sh
chmod +x /usr/sbin/monitoria/coleta.sh

# Criar diretorio de coleta do script no /var/monitoria/coleta
mkdir -p /var/monitoria/coleta/
chown -R monitor:monitor /var/monitoria/coleta

# Cria o arquivo para configurar qual o ip do servidor de monitoraçao
touch /var/monitoria/srvhost
chown monitor:monitor /var/monitoria/srvhost

# Configura o ip do servidor de monitoraçao no cliente
echo '======================================================'
echo ''
echo 'Digite o IP do servidor de monitoraçao'
read srvip
echo $srvip > /var/monitoria/srvhost
echo ''
echo 'IP do servidor de monitoraçao configurado!'
echo ''
echo '======================================================'


echo '======================================================'
echo ''
echo 'SCRIPT FINALIZADO'
echo ''
echo '======================================================'
