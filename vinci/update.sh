#!/bin/bash 
############################################################################################################################################################################################
##################################################################################   更新检查程序   #######################################################################################
############################################################################################################################################################################################
####内容说明：
####1、当脚本启动更新时，输入值为1.为程序报错或用户报错更新
#######  传递其他参数  #######
#$upcode                                更新模式
#$file_path                             为旧脚本目录路径
#$file_link                             脚本url链接
#$file_name                                  配置文件名称

####### 基本参数 ######
Ver=5                                   #版本号

####### 颜色
RED='\033[0;31m'
NC='\033[0m'

####### 主函数 ######
function main {
     (( upcode==1 )) || clear
     echo "正在检查$file_name文件更新..."
     
     while true; do
         #如果未获取到新版本文件
        if ! code="$(curl -s "$file_link")"; then  
            echo -ne "${RED}$file_name文件下载失败，请检查网络！即将返回...${NC}"
            countdown 10
            exit
        fi
        
        #如果文件存在，则开始检查更新。如果文件不存在，则跳过检查直接开始下载。
        if [ -e "$file_path" ]; then
        
             #已下载新版本文件，开始获取旧版本号及代码字符数量
             cur_Version=$(sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}' "$file_path") 
             num=$(n="$(cat "$file_path")" &&  echo "${#n}") 

             #如果已是最新版本
             if [ "$code" == "$(cat "$file_path")" ]; then
                  (( upcode==1 )) && ( warning; continue ) #如果是报错更新，现显示错误提醒，并重新检测更新
                  echo "${RED}$file_name文件当前已是最新版本V$cur_Version.$num！"
                  exit
                  
             #如果存在更新版本
             else 
                   #获取新版本号
                   Version=$( echo "$code" | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')
                   (( upcode==1 )) && echo "${RED} 当前${RED}$file_name文件存在错误！即将开始更新${NC}" 
                   echo "${RED}$file_name文件当前版本号为：V$cur_Version.$num"
                   echo "${RED}$file_name文件最新版本号为：V$Version.${#code}，即将更新..."
             fi
         fi 
         
         #开始下载
         curl -H 'Cache-Control: no-cache' -L "$file_link" -o "$file_path"
         echo "${RED}$file_name文件V"$Version.$(eval echo $num)"版本已下载\更新完成，即将继续！"
         countdown 10
         exit 
    done  
    
}

#######   保存提示  ####### 
 function warning {
      check_time=35    #检查更新时长
      tput sc  #保存当前光标位置
      local t=0
      n=$((n + 1))
      while true; do
            tput rc  #恢复光标位置
            tput el  #清除光标后内容
            t=$((t + 1)); if ((t > $check_time)); then break; fi   #每隔50s检查一次更新情况
            ti=$((( $((check_time-t)) > 9 )) && echo "$((check_time-t))" || echo "0$((check_time-t))")s
            [ "$a" == "true" ] && b="               正在等待服务器端版本更新，输入任意键退出...               " || b='                                                                         '
            [ "$a" == "true" ] && a="false" || a="true"
            echo -e "${RED}#################################################################################${NC}"
            echo -e "${RED}#################################################################################${NC}"
            echo -e "${RED}####                                                                         ####${NC}"
            echo -e "${RED}####   ${RED}$file_name文件错误！当前运行V$cur_Version.$num，检查程序版本V$Ver，第$n次检查$ti   ####${NC}"
            echo -e "${RED}####                                                                         ####${NC}"
            echo -e "${RED}####$b####${NC}"
            echo -e "${RED}####                                                                         ####${NC}"
            echo -e "${RED}#################################################################################${NC}"
            echo -e "${RED}#################################################################################${NC}"
            read -t 1 -n 1 input  #读取输入，在循环中一次1秒
            if [ -n "$input" ] || [ $? -eq 142 ] ; then
                echo "已取消继续更新${RED}$file_name文件..."
                countdown 10
                exit   
            fi
      done
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
