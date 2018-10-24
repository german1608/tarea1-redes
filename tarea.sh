#getIspProvider () {
#    echo $1
#    curl -s https://www.whoismyisp.org/ip/$1 | grep -oP '\bisp">\K[^<]+'
#}

read url
getIspProvider $(dig +short $url)
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

