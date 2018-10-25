usage () {
  echo "Uso: tarea.sh <domain>"
  echo
  echo "<domain>: Dominio del que se desea saber si esta \"arriba\""
  exit 1
}

if [ -z "$1" ]
then
  usage
fi

while true
    do 
    ping -c 1 $1 2> /dev/null
    if [ $? == 0 ]
    then
        echo "url is up"
    else
        gtway=$(ip route | egrep default | cut -d' ' -f 3)
        echo $gtway
        ping -c 1 $gtway 2> /dev/null
        if [ $? == 0 ]
        then
            echo "gateway is up, url down"
        else
            priv_ip=$(ip addr show wlan0 | grep -Po 'inet \K[\d.]+')
            echo $priv_ip
            ping -c 1 $priv_ip 2> /dev/null
            
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

