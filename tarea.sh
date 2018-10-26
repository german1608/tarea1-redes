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

getMachineIp () {
    ip addr show $(getDefaultInterface) | grep -Po 'inet \K[\d.]+'
}

if [ -z "$1" ]
then
  usage
fi

url=$1
while true
    do
    message
    # Hacemos ping al dominio para ver si esta up.
    pingdomain $url
    # El codigo de retorno 2 indica que el dominio
    # suministrado no fue resolvido por un dns. El problema puede ser
    # el dns del dominio
    if [ $? == 2 ]
    then
        message="La direccion ip de $url no fue resolvida"
    # Si es 1, es que el dominio no le dio respuesta.
    else if [ $? == 1 ]
        message="El dominio $url esta down"
        gtway=$(getGateway)
        # Si el gtway es "" es por que la computadora esta en una red
        if [ "$gtway" = "" ]
        then
            message="La red de la computadora local no tiene un gateway asignado"
        # En otro caso, hacemos ping a ver si el gateway esta vivo
        else
            pingdomain $gtway
            if [ $? != 0 ]
            then
                message="Hay un problema con el gateway de la red"
                # Pudieramos ver si el problema es que no tenemos ip asignada
                # Para ver eso, vemos la interfaz que se esta usando
                interface=$(getDefaultInterface)
                priv_ip=$(getMachineIp)
                if []
                pingdomain $priv_ip

                if [ $? == 0 ]
                then
                    echo "ip private is up, gateway is down"
                else
                    echo "chao"
                fi
            fi
        fi
    fi
    if [ "$message" != "" ]
    then
        mailAdmin $message
    fi
    sleep 5
done

