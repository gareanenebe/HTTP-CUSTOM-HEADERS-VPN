#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
SCOLOR='\033[0m'
cat << EOF > redsocksSetup.sh
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
SCOLOR='\033[0m'
if [ -f "redsocksv" ] 
then 
echo "${GREEN}Redsocks installed ${SCOLOR}"
else
echo -e "${GREEN} COMPILLING REDSOCKS BINARY ...${SCOLOR}"
sleep 1
unzip redsocks 
cd redsocks 
make
cp redsocks redsocksv
cp redsocksv ../
cd ..
unzip dns2socks.zip
cd dns2socks
make
chmod 777 dns2socks
cp dns2socks "$PREFIX"/bin
fi
EOF
bash redsocksSetup.sh
rm redsocksSetup.sh
rm -rf redsocks
rm -rf dns2socks
clear


m=`cat settings.ini |sed -e '1p' -e '/connection_mode/!d'| awk '{print $3}'`
mode="$m"

killprocess() {
echo -e "${RED} KILLING PROCESS...." 
python3 pidkill.py >>/dev/null 
rm -rf logs.txt
echo -e " DONE ${SCOLOR}"
}

function connect() {
        localport="$1"

	if [ $mode = 0 ] 
        then
           screen -AmdS nohup python3 ssh.py 0 _
        elif [ $mode = "1" ]
	  then
               screen -AmdS nohup python3 tunnel.py $localport
               sleep 1
               screen -AmdS nohub sudo python3 ssh.py 1 $localport
	elif [ "$mode" = '2' ] || [ "$mode" = '3' ]
		then 
			screen -AmdS nohup python3 tunnel.py $localport
                        sleep 1
			screen -AmdS pythonwe python3 ssh.py 1  $localport 
	else
		echo -e "${RED}wrong choice\ntry again${SCOLOR}"
		killprocess
		exit
	fi

	echo -e "${YELLOW}---logs----${SCOLOR}"

	sleep 10
	cat logs.txt

	var=`cat logs.txt |tail -n 1 | grep "CONNECTED SUCCESSFULLY"|awk '{print $2}'`
        
	if [ "$var" = "SUCCESSFULLY" ];then 
		echo -e "${GREEN}---Tunneling  starts-----${SCOLOR}"
		chmod +x proxification
		sudo ./proxification >> /dev/null 
	
               
		sudo iptables -t nat -F OUTPUT
		
	else
		echo -e "${RED}Failed to connect ... Try again${SCOLOR}"
	fi
}
connect 9090
for i in {9091..9099}
do 
	
	killprocess
	connect $i 
done

