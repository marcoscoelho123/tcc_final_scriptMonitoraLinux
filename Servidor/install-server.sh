#!/bin/bash
# Pre-requisitos - Servidor
# Instalar o mysql, ubuntu LAMP, phpmyadmin e configurar o php
apt-get install apache2 -y
apt-get install mysql-server -y
apt-get install php libapache2-mod-php php-mysql -y
apt-get install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
phpenmod mbstring
systemctl restart apache2

# instalar o iostat, rsync
apt-get install sysstat -y
apt-get install rsync -y

# Instalar tarefa na crontab para captura dos arquivos e atualizaçao do banco
if [ `crontab -l |grep srv-coleta.sh` -eq '']; then
crontab -l | { cat; echo "# Serviço de monitoraçao, caputra os arquivos"; echo "* * * * * sleep 10; bash /usr/sbin/monitoria/srv-coleta.sh"; } | crontab -
else
echo '======================================================'
echo ''
echo 'CRONTAB SRV-COLETA JÁ ESTÁ CONFIGURADA'
echo ''
echo '======================================================'
fi



if [ `crontab -l |grep bdsend.sh` -eq '']; then
crontab -l | { cat; echo "# Envia a coleta para o banco de dados"; echo "* * * * * sleep 20; bash /usr/sbin/monitoria/bdsend.sh"; } | crontab -
else
echo '======================================================'
echo ''
echo 'CRONTAB BDSEND JÁ ESTÁ CONFIGURADA'
echo ''
echo '======================================================'
fi

# Configurar o rsync (/etc/rsyncd.conf /etc/rsyncd.passwd)
cp ./srv-rsyncd.conf /etc/rsyncd.conf
echo senha > /etc/rsyncd.passwd
chmod 0640 /etc/rsyncd.conf
chmod 0600 /etc/rsyncd.passwd

# habilitar rsync e iniciar
systemctl enable rsync; systemctl start rsync

# criar usuario da monitoraçao
useradd -c "Usuario de monitoraçao" monitor

# Criar arquivo de senha do usuario da monitoraçao para acessar o banco
install -m 700 -d /home/monitor
install -m 600 /dev/null /home/monitor/monitor@localhost.cnf
echo "[client]" >> /home/monitor/monitor@localhost.cnf
echo 'password="SenhaInicial"' >> /home/monitor/monitor@localhost.cnf
chown -R monitor:monitor /home/monitor

# criar diretorio do script no /usr/sbin/monitoria
mkdir -p /usr/sbin/monitoria
chown root:monitor /usr/sbin/monitoria

# Enviar o script para o diretorio do script e atribuir a permissão de execuçao 
cp ./srv-coleta.sh /usr/sbin/monitoria/
cp ./bdsend.sh /usr/sbin/monitoria/

# Script que cria os diretorios de monitoraçao:
cp ./update.sh /usr/sbin/monitoria/

# Atribui permissão de exeução aos sripts
#chmod +x /usr/sbin/monitoria/srv-coleta.sh
chmod +x /usr/sbin/monitoria/update.sh

# criar diretorio da coleta dos servidores
mkdir -p /var/monitoria/coleta
touch /var/monitoria/hosts.list
chown -R monitor:monitor /var/monitoria

# Cria o banco de dados e o usuario monitor no banco
mysql < create-bd

echo '======================================================'
echo ''
echo 'SCRIPT FINALIZADO'
echo ''
echo '======================================================'