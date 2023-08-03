Version=1.00  #版本号  

###### 企业微信消息推送 ######
#webhook参数
webhook='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=615a90ac-4d8a-48f1-b396-1f4bfbc650cd'
function notifier {
# 使用curl发送POST请求，这里使用的JSON格式的数据
curl "$webhook" \
     -H 'Content-Type: application/json' \
     -d "{
     \"msgtype\": \"text\",
     \"text\": {
         \"content\": \"【服务器信息】\n$1\"
     }
}" >/dev/null 2>&1
}

#######   进度条  ####### 
function bar() {
    time=$1 #进度条时间
    #$2  第一行文本内容
    #$3  第二行文本内容
    #$4  是否可退
    #$5  退出提醒
    block=""
    echo -e "\033[1G$block"$2"···"
    printf "输入任意键退出%02ds" $time
    for i in $(seq 1 $1); do
       time=$((time-1))
       block=$block$(printf "\e[42m \e[0m")
       echo -e "\033[1F\033[1G$block"$2"···"
       printf "输入任意键可退出...%02ds" $time
       read -t 1 -n 1 input
           if [ -n "$input" ] || [ $? -eq 142 ] && [[ $4 == "true" ]]; then
               echo "$5"
               return 0 
           fi  
    done       
    echo
    printf "\033[1A\033[K%s\n" "$3"
    return 1
}
