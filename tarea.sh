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
    ping -c 1 ldc.usb.ve 2> /dev/null
    if [ $? == 0 ]
    then
        echo "hola"
    else
        echo "chao"
    fi
    sleep 5
done

