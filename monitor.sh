#!/bin/bash
deny_ip(){
    netstat -an|grep "#服务器公网IP#:80"| grep -v LISTEN| grep -v ESTABLISHED|awk '{print $5;}'|awk -F ':' '{print $1;}'|sort|uniq -c|awk -F'[: ]' '{print $7"="$8;}'
}

for _un in $(deny_ip)
do
    if [ $(echo $_un|awk  -F'=' '{print $1;}') -gt 10 ]
    then
        iptables -I INPUT -s $(echo $_un|gawk -F'=' '{print $2;}') -p tcp --dport 80 -j DROP
fi
done
