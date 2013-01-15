一些简单的 awk 使用例子,有些是平常需求写的，有些是网上看到保存的。
 删除非连续重复行
<pre lang='php'>
awk '! a[$0]++' filename  
</pre>
计算日志sum以及均值
统计apache平均相应时间
<pre lang='php'>
awk 'BEGIN{sum = 0;} {sum += $6;} END {print "Sum: ",sum;print "Average:",sum/NR;}' 20130101-access_log
</pre>
统计代码总行数以及每个文件平均行数
<pre lang='php'>
for i in $(find . -name "*.php"); do  wc -l $i | awk '{print $1}' ; done | awk 'BEGIN{s = 0} {s += $0} END{print "sum: ",s; print "avg: ",s/NR;}';
</pre>
去掉所有换行符
<pre lang='php'>
awk '\{printf("%s", $0)\}' filename
</pre>
去掉所有空行
<pre lang='php'>
awk '\{if (NF > 0) print $0;\}' filename
<pre>
查看TIME_WAIT及各种状态TCP连接的数量
<pre lang='php'>
netstat -atn | awk '/^tcp/{a[$6]++} END{for(i in a ){printf("%s\t%d\n",i,a[i])}}'
</pre>

<a href="http://www.wenan8.com/blog/archives/543" target="_blank">awk的简单使用例子(一)</a>
统计某段时间每秒钟nginx请求数
<pre lang='php'>
grep "2012:17:1" nginx_02 | awk -F"[: ]" '{t=$5 ":" $6 ":" $7;v[t]++;}END{for (i in v){print i, " ", v[i]}}'| sort 
</pre>
<a href="http://www.wenan8.com/blog/archives/541" target="_blank">统计每日ip数并打印前10的ip及访问次数</a>
<pre lang='php'>
cat logname | awk '{x[$1]++}END{for(ip in x){ print ip,x}}' | sort -n -k2 -r | head -n10
</pre>
使用awk截断字符串
<pre lang='php'>
#获得$XPIFILE文件的hash
HASH=`sha1sum $XPIFILE |awk '{print $1}'`
#从<em:version>0.1.3</em:version>中获得当前版本号
VERSION=`awk '/(<em:version>([^<]*)</em:version>)/' install.rdf |awk -F '>' '{print $2}'|awk -F '<' '{print $1}'`
</pre>
#awk使用 substr
<pre lang='php'>
grep "2013-01-02 1[89]:" phperrorlog_current| awk '{a[substr($4,0,5)]++} END {for(i in a) {printf("%s\t%d\n", i, a[i])}}' | sort -n
</pre>
#awk切分field时括号的转义
#在centos中默认的awk是gawk，而在ubuntu中默认是mawk，可以使用awk –version 或者 awk -W version查看使用什么版本的awk。
#使用mawk直接用(转义即可，在gawk中使用转义而且是单引号。
<pre lang='php'>
#以下例子是查找abc.css中所有的背景图片(去掉重复的)
# 只对mawk有效
grep 'url(\.\.' abc.css |awk -F'url\(' '{print $2}'|awk -F")" '{print $1}'|sort -u
grep 'url(\.\.' abc.css |awk -F"url\(" '{print $2}'|awk -F")" '{print $1}'|sort -u
# mawk和gawk都ok
grep 'url(\.\.' abc.css |awk -F'url\\(' '{print $2}'|awk -F")" '{print $1}'|sort -u
</pre>
