#!/usr/bin/env bash
Help(){
    cat<<EOF
DESCRIPTION:
    this bash can help you realize the batch statistics of web server access logs
 or
Usage:
    bash ${0} [Options]:
Available options:
    -h          显示这个帮助文档
    -a          统计访问来源主机TOP 100和分别对应出现的总次数
    -p          统计访问来源主机TOP 100 IP和分别对应出现的总次数
    -m          统计最频繁被访问的URL TOP 100
    -r          统计不同响应状态码的出现次数和对应百分比
    -f          分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
    -u          给定URL输出TOP 100访问来源主机
EOF
}

File="web_log.tsv"
Get_Top100_hostname(){
    printf "=====Top 100 hostname and its total apperance=====\n"
    awk -F '\t' '
    NR>1{
        host[$1]++;
    }
    END{
        for(key in host){
            printf "%s:%d\n",key,host[key]
        }
    }
    ' $File | sort -n -r -k 2 -t : | head -n 100| 
    awk -F ':' '{printf "%s%-30s\t%s%03d\n","Host:",$1,"Apperance:",$2}'
    return  
}

Get_Top100_IP(){
    printf "=====Top 100 IP and its totla apperance=====\n"
    awk -F '\t' '
    NR>1{
        if($1~/([0-9]{1,3}\.){3}[0-9]{1,3}/){
            ip[$1]++;
        }
    }
    END{
        for(key in ip){
            printf "%s:%d",key,ip[key]
        }
    }' $File | sort -n -r -k 2 -t : | head -n 100| 
    awk -F ':' '{printf "%s%-30s\t%s%03d\n","IP:",$1,"Apperance:",$2}'
    return  
}

Get_Top100_URL(){
    printf "=====Top 100 URL and its totla apperance=====\n"
    awk -F '\t' '
    NR>1{
        URL[$5]++
    }
    END{
        for(key in URL){
            print "%s:%d",key,URL[key]
        }
    }' $File | sort -n -r -k 2 -t : | head -n 100| 
    awk -F ':' '{printf "%s%-55s\t%s%03d\n","URL:",$1,"Apperance:",$2}'
    return 
}

GetStatus(){
    printf "=====Status Code,The number of occurrences,Ratio=====\n"
    awk -F '\t' '
    BEGIN{
        tot=0;
    }
    NR>1{
        status[$6]++;tot++;
    }
    END{
        for(key in status){
            printf "Status:%d\tTimes:%8d\tRatio:%.3lf\n",key,sta[key],sta[key]/tot    
        }
    }
    ' $File
}

Get4xUrl(){
    printf "=Top 10 URLs Corresponding To Status Codes And The Total Number Of Occurrences=\n"
    printf "===Status:%d===\n" 403
    awk -F '\t' '
    NR>1{
        if($6~/403/){
            url[$5]++;
        }
    }
    END{
        for(i in url){
            printf "%s:%d\n",i,url[i]
        }     
    }
    ' $File | sort -n -r -k 2 -t : | head -n 10 | 
     awk -F ':' '
       {printf "%s%-55s\t%s%d\n","Url:",$1,"Apperance:",$2}
    '  
    printf "===Status:%d===\n" 404
    awk -F '\t' '
    NR>1{
    if($6~/404/){
            url[$5]++;
        }
    }
    END{
        for(i in url){
            printf "%s:%d\n",i,url[i]
        }     
    }
    ' $File | sort -n -r -k 2 -t : | head -n 10 | 
     awk -F ':' '
       {printf "%s%-55s\t%s%d\n","Url:",$1,"Apperance:",$2}
    '  
    return
}

showUrl(){
    printf "===============Show Url for %s\t===\n" "$1"
    awk -F '\t' -v url="$1" '
    NR>1{
        if($5==url){
            host[$1]++
        }
    }
    END{
        for(i in host){
            printf "%s:%d\n",i,host[i]
        }     
    }
    ' $File | sort -n -r -k 2 -t : | head -n 100 | 
     awk -F ':' '
       {printf "%s%-55s\t%s%d\n","Host:",$1,"Apperance:",$2}
    '  
    return 
}

while getopts ":hapmrfu:" opt;do
    case $opt in
        h)Help;exit ;;
        a)Get_Top100_hostname;;        
        p)Get_Top100_IP;;
        m)Get_Top100_URL;;
        r)GetStatus;;
        f)Get4xUrl;;
        u)showUrl "${OPTARG}";;
        *)printf "Error\n";Help;;
    esac
done