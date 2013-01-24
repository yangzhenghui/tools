#!/bin/bash
# collect server03  server04  server05  cps log  
log_name=`date +%Y-%m-%d`".log"
scp liuzhichao@server03:/opt/log/httpd/r.union.meituan.com-access_log.1 /opt/log/collectlog/server03.log
scp liuzhichao@server04:/opt/log/httpd/r.union.meituan.com-access_log.1 /opt/log/collectlog/server04.log
scp liuzhichao@server05:/opt/log/httpd/r.union.meituan.com-access_log.1 /opt/log/collectlog/server05.log
MYSQL="/usr/bin/mysql"
USERNAME="root"
PASSWORD=""
DB="union"
cd /opt/log/collectlog/
#echo `pwd`
cat server03.log > $log_name
cat server04.log >> $log_name
cat server05.log >> $log_name
cat $log_name | grep "/cps/bd" |  awk '\
    BEGIN{
        #sql=sprintf("mysql -u union -p123456 --silent --column-names=false --default-character-set=utf8 --database=union -e ")
        #system(sql) 
        mons["Jan"]=1;mons["Feb"]=2;mons["Mar"]=3;
        mons["Apr"]=4;mons["May"]=5;mons["Jun"]=6;
        mons["Jul"]=7;mons["Aug"]=8;mons["Sep"]=9;
        mons["Oct"]=10;mons["Nov"]=11;mons["Dec"]=1;
    }
        {
        gsub(/:/," ",$4);
        gsub(/\//," ",$4);
        gsub(/\[/,"",$4);
        split($4,t);
        str = t[3] " " mons[t[2]] " " t[1] " " t[4] " " t[5] " " t[6] 
        time = mktime(str)
        if(time > 0) {
            split($7,s,"&")
            split($7,urpid,"tn=")
            split(s[1],type,"/")
            split(s[1],url,"=")
            split(type[3],m,"?")
            print $1,time,url[2],urpid[2],m[1],$9
        }else{
            next    
        }
    }
    ' | sort -n -k2 | awk '\
        {
            if(NF == 6 && $2 ~/^[0-9]+$/ && $6 ~ /^[0-9]+$/)
                printf("insert into `%s` (ip,access_time,url,urpid,type,code) values (\"'%s'\",\"'%s'\",\"'%s'\",\"'%s'\",\"'%s'\",\"'%s'\");\n","baiduvisit",$1,$2,$3,$4,$5,$6);
                
        }
    ' > tmp.sql
$MYSQL -u $USERNAME --password=$PASSWORD -D $DB < tmp.sql
rm tmp.sql
rm server*
rm $log_name 
