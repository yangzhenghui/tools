#!/bin/bash
# cut seo log for seo@meituan.com  @giant05
# log_path /opt/log/seo/keywords-date.txt from liufeng03 @ web 
log_path="/opt/log/seo/"
log_name="keywords"`date -d yesterday +%Y-%m-%d`".txt"
new_name="new"`date -d yesterday +%Y-%m-%d`".log"
sedscr=`pwd`"/sedscr"
#echo $log_path$log_name
if [ ! -s $log_path$log_name ]; then
    echo 'file not found or file is empty'
    exit 0 
else
    sed -i '/^\s*$/d' $log_path$log_name
    sed -i -f $sedscr $log_path$log_name
fi
if [ -s $log_path$log_name ]; then
    cat $log_path$log_name | sort -k2 | awk ' \
        BEGIN {
           FS="\t" 
        }
        {
            line = $1 "\t"  $2 "\t"  $3 "\t"  $4 "\t"  $5 "\t"  $6
            gsub(/-/," ",$2);
            gsub(/:/," ",$2);
            time = mktime($2)
            if(!newdata[$1$4$6] || time - newdata[$1$4$6]>1800){
                newdata[$1$4$6] = time;
                new[line] = line
            }
        }
        END{
            for (i in new) print new[i]
        }
    ' | sort -k1 > $log_path$new_name
fi
sed -i -f $sedscr $log_path$new_name
