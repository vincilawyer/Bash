#!/bin/bash 
############################################################################################################################################################################################
##############################################################################   vinci更新检查脚本源代码   ########################################################################################
############################################################################################################################################################################################

####### 基本参数 ######
Ver=010       #检查脚本版本号
name="vinci"  #脚本名称
#$current_Version 为当前版本号，由运行本脚本时传递该变量
#$force           为是否强制更新，true为强制更新，由运行本脚本时传递该变量

####### 路径 ######
#Vultr-Debian11.sh文件网址
link_Vultr_Debian11="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh"
#脚本保存路径
download_path="/usr/local/bin"

####### 主函数 ######
function main {
clear
#检查最新版本号
echo "正在检查最新版本($Ver)..."
Version=$(curl -s "$link_Vultr_Debian11" | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')
        
#下载脚本请求
if [[ -z "$current_Version" ]]; then
    echo "正在下载Vultr-Debian11脚本..."
    download "Linux管理系统V"$Version"版本已下载完成，即将进入系统！"   
    exit 1
#强制更新
elif [ "$force" == "true" ]; then
    echo "当前版本号为：V$current_Version"
    echo "最新版本号为：V$Version，即将强制更新脚本..."
    download "Linux管理系统V"$Version"版本已强制更新完成，即将重启管理系统！"
    exit 1
#已是最新
elif [[ "$current_Version" == "$Version" ]]; then
    echo "当前已是最新版本(V$Version)，无需更新！"
    exit 2
#正常更新
else 
    echo "当前版本号为：V$current_Version"
    echo "最新版本号为：V$Version，即将更新脚本..."
    download "Linux管理系统V$Version版本已更新完成，即将进入系统！"
    exit 1
fi
    exit 2
  }
  
####### 下载vinci脚本 ###### 
function download {
    notice="$1"
    while true; do     
        if wget --no-cache "$link_Vultr_Debian11" -O "$download_path"/"$name" ; then
            chmod +x "$download_path/$name"
            echo "$notice"
            sleep 1
            vinci
            result=$?
            if [ "$result" == "0" ]; then                          #如果脚本正常运行，则退出
               exit
            else                                                    #如果脚本运行错误，则强制更新
               current_Version=$(sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}' $download_path/$name)
               echo -e "${RED}###################################################${NC}"
               echo -e "${RED}#####  请注意，当前脚本运行出现错误！版本号：V$current_Version ######${NC}"
               echo -e "${RED}###################################################${NC}"
               if bar 60 "即将尝试重新更新" "开始重新更新" true "已取消重新更新！"; then return; fi
               Version=$(curl -s "$link_Vultr_Debian11" | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')
               notice=download "Linux管理系统V"$Version"版本已重新更新完成，即将重启管理系统！"
            fi
        else
            exit 3
        fi    
  done
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
       block=$block$(printf "\e[42m \e[0m")
       echo -e "\033[1F\033[1G$block"$2"···"
       printf "输入任意键可退出...%02ds" $time
       read -t 1 -n 1 input
           if [ -n "$input" ] && [[ $4 == "true" ]]; then
               echo "$5"
               return 0
           fi  
           time=$((time-1))
    done       
    echo
    printf "\033[1A\033[K%s\n" "$3"
    return 1
}





main
