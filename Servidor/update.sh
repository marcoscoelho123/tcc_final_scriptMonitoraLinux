#!/bin/bash
# Script que cria os diretorios dos servidores a serem monitorados
for x in `cat /var/monitoria/hosts.list`
	do mkdir /var/monitoria/coleta/$x
	chown monitor:monitor /var/monitoria/coleta/$x
done