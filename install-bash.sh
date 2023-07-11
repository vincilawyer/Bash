#!/bin/bash 
############################################################################################################################################################################################
##############################################################################   vinci更新检查脚本源代码   ####################################################################################
############################################################################################################################################################################################
####内容说明：
####1、关于脚本返回值：当下载成功并正常运行脚本，脚本返回值为1；当脚本无需更新，返回为2；当脚本下载失败未更新，返回为3 ；当脚本运行出现错误，用户取消更新，返回为4。

####### 基本参数 ######
Ver=016           #检本查脚本版本号
Version=""        #最新版本号
new_name="vinci"  #新脚本名称
new_path="/usr/local/bin/$new_name"     #新下载脚本保存路径
#$current_Version 为旧版本号，由运行本脚本时传递该变量
#$download_path   为脚本当前的目录路径
#$name            为脚本当前名称
#$force           为强制更新模式，1为用户强制更新，2为自启动程序报错强制更新，由运行本脚本时传递该变量
position=$( [ -z "$download_path" ] && echo "$new_path" || echo "$download_path"/"$name" )     #脚本路径
name=$( [ -z "$name" ] && echo "$new_name" || echo "$name" )                                   #脚本名称

####### 下载网址 ######
#Vultr-Debian11.sh文件网址
link_Vultr_Debian11="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh"

####### 颜色
RED='\033[0;31m'

####### 主函数 ######
function main {
         
    #获取最新版本号
    Version=$(curl -s "$link_Vultr_Debian11" | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')
    #用户强制更新
    if [ "$force" == "1" ]; then
        download
    #自启动程序错误强制更新
    elif [ "$force" == "2" ]; then
        warning
        download
    #已是最新
    elif [[ "$current_Version" == "$Version" ]]; then
        echo "当前已是最新版本(V$Version)，无需更新！"
        exit 2                                            #无需更新返回值
    #首次下载、用户强制更新、版本滞后更新
    else
        download
    fi
  }
  
####### 下载vinci脚本 ###### 

function download {
    clear
    echo "更新程序运行中($Ver)..."
    if [ -e "$position" ]; then 
        echo "当前版本号为：V$current_Version"
        echo "最新版本号为：V$Version，即将更新脚本..."
        echo "旧脚本备份中"
        if [ ！"$force" == "2" ] ; then cp -f "$position" "$position"_backup; fi
    else
        echo "最新版本号为：V$Version，即将下载脚本..."
    fi
    
    while true; do    
        #再次获取最新版本号
        Version=$(curl -s "$link_Vultr_Debian11" | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')   
        if wget --no-cache "$link_Vultr_Debian11" -O  "$position" ; then
            chmod +x "$position"
            echo "Linux管理系统V"$Version"版本已下载\更新完成，即将进入系统！"
            countdown 10
            $name 1      #启动新脚本
            result=$?
            if [ "$result" == "0" ]; then                          #如果脚本正常运行，则退出
               exit 1                                            
            else                                                   #如果脚本运行错误，则强制更新
               warning                                             #已更新脚本并正常运行的返回值
            fi
        else
            echo -n "vinci脚本下载失败，请检查网络！"
            exit 3                                                #未更新脚本的返回值                                          
        fi    
  done
} 
#######   保存提示  ####### 
 function warning {
      current_Version=$(sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}' "$position")
      echo -e "${RED}##################################################################################${NC}"
      echo -e "${RED}######  请注意，当前脚本运行出现错误！当前版本号：V$current_Version，最新版本号：V$Version #######${NC}"
      echo -e "${RED}##################################################################################${NC}"
      if bar 60 "即将尝试重新更新" "开始重新更新" true "已取消重新更新！"; then 
           if bar 30 "即将回滚至旧版本" "开始回滚" true "已取消回滚！"; then exit 4; fi 
           cp -f "$position"_backup "$position" 
           echo "已回滚至旧版本！"
           exit 4         #脚本运行错误，取消更新的返回值
      fi     
      clear
      echo "更新程序运行中($Ver)..."
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
           if [ -n "$input" ] && [[ $4 == "true" ]]; then
               echo "$5"
               return 0 
           fi  
    done       
    echo
    printf "\033[1A\033[K%s\n" "$3"
    return 1
}
#######   倒计时  ####### 
function countdown {
    local from=$1
    tput sc  # Save the current cursor position
    while [ $from -ge 0 ]; do
        tput rc  # Restore the saved cursor position
        tput el  # Clear from cursor to the end of the line
        printf "%02ds" $from  # Print the countdown
        if $(read -s -t 1 -n 1); then break; fi
        ((from--))
    done
    echo
}
######  运行主函数  ######
main
