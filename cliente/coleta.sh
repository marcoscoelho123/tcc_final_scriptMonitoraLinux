#!/bin/bash
# Caminho dos arquivos coletados /var/monitoria/coleta
# Serviço associado monitoria.service | monitoria.service
# coleta date e hora
#
# Especifica qual o servidor de monitoraçao
srvhost=`cat /var/monitoria/srvhost`

# coleta uso de CPU
iostat |awk 'NR==4 {print (($6-100)*(-1))}' > /var/monitoria/coleta/cpu
# Altera a pontuaçao de ',' para '.' , para que o valor possa ser inserido no banco
sed -i 's/,/./g' /var/monitoria/coleta/cpu

# coleta memoria
free -m | awk 'NR==2 {print $2}' > /var/monitoria/coleta/memory-total # memoria total
free -m | awk 'NR==2 {print $3}' > /var/monitoria/coleta/memory-used # memoria usada
free -m | awk 'NR==2 {print $7}' > /var/monitoria/coleta/memory-available # memoria disponivel
free -m | awk 'NR==3 {print $2}' > /var/monitoria/coleta/swap-total # swap total
free -m | awk 'NR==3 {print $3}' > /var/monitoria/coleta/swap-used # swap usada
free -m | awk 'NR==3 {print $4}' > /var/monitoria/coleta/swap-free # swap livre

# coleta file systems
# ponto de montagem e %usada
df -h | awk '{print $6,$5}'| grep -vi use|grep -vi mounted > /var/monitoria/coleta/df

# coleta conexoes ativas
#netstat -natp

# coleta IO
# Coleta a partiçao e o uso dela
iostat -dx | grep -v "loop" | grep -v "fd0" | grep -v "scd" | awk 'NR==4 {print $1,$21}' > /var/monitoria/coleta/io
# Altera a pontuaçao de ',' para '.' , para que o valor possa ser inserido no banco
sed -i 's/,/./g' /var/monitoria/coleta/io

# Envia os arquivos monitorados para o servidor banco
# rsync -rav --password-file=/etc/rsyncd.passwd monitor@$srvhost::data /var/monitoria/coleta/coleta/$srvhost