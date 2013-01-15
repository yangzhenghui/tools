#!/bin/bash
## cut log
cat zhao.meituan.com-access_log.1 | awk '\
    {
        x[$1]++
    }
    END{
        for (ip in x)
            print ip,x[ip]
    } 
'  | sort -n -k2 -r | head -n10
