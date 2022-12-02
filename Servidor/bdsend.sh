#!/bin/bash
# Script de envio da coleta para o banco de dados.
#
# Atribui os valores das variaveis
bdsend="mysql --defaults-extra-file=/home/monitor/monitor@localhost.cnf -u monitor monitoria -e"
dia=`date -I`
hora=`date | awk '{print $5}'`

# captura os ips dos servidores
for x in `cat /var/monitoria/hosts.list`
        do

                # separa os dados do df para poder preencher o banco
                cat /var/monitoria/coleta/$x/df | awk '{print $1}' > /var/monitoria/coleta/$x/fs
                cat /var/monitoria/coleta/$x/df | awk '{print $2}' > /var/monitoria/coleta/$x/fs-uso

                # separa os dados do IO para poder preencher o banco
                cat /var/monitoria/coleta/$x/io | awk '{print $1}' > /var/monitoria/coleta/$x/io-part
                cat /var/monitoria/coleta/$x/io | awk '{print $2}' > /var/monitoria/coleta/$x/io-uso


                # Atualiza as tabelas "ip, dia e hora", para que as tabelas relacionadas (coleta, filesystems) possam ser atualizadas.
				# Atualiza as tabelas "ip para que as tabelas relacionadas (coleta, filesystems) possam ser atualizadas.
                $bdsend "INSERT INTO ip VALUES ('$x');"


        # Atualiza a tablea filesystems
                count=1
                while [ $count -le `cat /var/monitoria/coleta/$x/fs | wc -l` ]
                        do
                        fs=`awk NR==$count < /var/monitoria/coleta/$x/fs`
                        used=`awk NR==$count < /var/monitoria/coleta/$x/fs-uso`
                        $bdsend "INSERT INTO filesystems VALUES ('$fs', '$used', '$hora', '$dia', '$x');"
                        count=$(( $count + 1))
                done

                # Atualiza a tabela coleta
                fcpu=`cat /var/monitoria/coleta/$x/cpu`
                fmem_total=`cat /var/monitoria/coleta/$x/memory-total`
                fmem_used=`cat /var/monitoria/coleta/$x/memory-used`
                fmem_available=`cat /var/monitoria/coleta/$x/memory-available`
                fswap_total=`cat /var/monitoria/coleta/$x/swap-total`
                fswap_used=`cat /var/monitoria/coleta/$x/swap-used`
                fswap_free=`cat /var/monitoria/coleta/$x/swap-free`
                $bdsend "INSERT INTO coleta VALUES ('$fcpu', '$fmem_total', '$fmem_used', '$fmem_available', '$fswap_total', '$fswap_used', '$fswap_free', '$hora', '$dia', '$x');"

                # Atualiza a tabela IO
                count=1
                while [ $count -le `cat /var/monitoria/coleta/$x/io | wc -l` ]
                        do
                        particao=`awk NR==$count < /var/monitoria/coleta/$x/io-part`
                        uso=`awk NR==$count < /var/monitoria/coleta/$x/io-uso`

                        $bdsend "INSERT INTO IO VALUES ('$particao', '$uso', '$hora', '$dia', '$x');"
                        count=$(( $count + 1))
                done
done

echo '======================================================'
echo ''
echo 'SCRIPT FINALIZADO'
echo ''
echo '======================================================'