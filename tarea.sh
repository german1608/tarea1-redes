usage () {
  echo "Uso: tarea.sh <domain>"
  echo
  echo "<domain>: Dominio del que se desea saber si esta \"arriba\""
  exit 1
}

mailAdmin () {
    body=$1
    subject="Error en la red"
    adminEmail=$(whoami)@$(hostname)
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
    message=""
    # Hacemos ping al dominio para ver si esta up.
    pingdomain $url
    ret=$?
    # El codigo de retorno 2 indica que el dominio
    # suministrado no fue resuelto por un dns. El problema puede ser
    # el dns del dominio
    if [ ret = 2 ]; then
        message="La direccion ip de $url no fue resolvida"
    # Si es 1, es que el dominio no le dio respuesta.
    elif [ ret = 1 ]; then
        message="El dominio $url esta down"
        gtway=$(getGateway)
        # Si el gtway es "" es por que la computadora esta en una red
        if [ "$gtway" = "" ]; then
            message="La red de la computadora local no tiene un gateway asignado"
        # En otro caso, hacemos ping a ver si el gateway esta vivo
        else
            pingdomain $gtway
            if [ $? != 0 ]; then
                message="Hay un problema con el gateway de la red"
                # Pudieramos ver si el problema es que no tenemos ip asignada
                # Para ver eso, vemos la interfaz que se esta usando
                interface=$(getDefaultInterface)
                priv_ip=$(getMachineIp)
                if [ "$interface" = "" ]; then
                    message="La interfaz de red no esta funcionando correctamente"
                else
                    if [ "$priv_ip" = "" ]; then
                        message="La computadora local no tiene ip asignada"
                    else
                        true;
                        # Si pasa por aca, es culpa del gateway. Ya el mensaje
                        # se asigno arriba.
                    fi
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

