usage () {
  echo "Uso: tarea.sh <domain>"
  echo
  echo "<domain>: Dominio del que se desea saber si esta \"arriba\""
  exit 1
}

mailAdmin () {
    body=$1
    subject="Error en la red"
    adminEmail="14-10924@usb.ve"
    echo body | mail -s $subject $adminEmail
}

pingdomain () {
    ping -c1 $1 &> /dev/null 2> /dev/null
}

getDefaultInterface () {
    route | egrep default | awk '{ print $8 }'
}

getGateway () {
    ip route | egrep default | cut -d' ' -f 3
}

getExternalIp () {
    ip addr show $(getDefaultInterface) | grep -Po 'inet \K[\d.]+'
}

if [ -z "$1" ]
then
  usage
fi

while true
    do
    pingdomain $1
    if [ $? == 0 ]
    then
        echo "url is up"
    else
        gtway=$(getGateway)
        echo $gtway
        pingdomain $gtway
        if [ $? == 0 ]
        then
            echo "gateway is up, url down"
        else
            interface=$(getDefaultInterface)
            priv_ip=$(getIxternalIp)
            echo $priv_ip
            pingdomain $priv_ip

            if [ $? == 0 ]
            then
                echo "ip private is up, gateway is down"
            else
                echo "chao"
            fi
        fi
    fi
    sleep 5
done

