#!/bin/bash
# Script para coletar os arquivos dos servidores monitorados
# o comando do rsync ira capturar os dados monitorados.

for x in `cat /var/monitoria/hosts.list`
do (rsync -rav --password-file=/etc/rsyncd.passwd monitor@$x::data /var/monitoria/coleta/$x &)
done