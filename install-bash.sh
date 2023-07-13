#!/bin/bash 
############################################################################################################################################################################################
##############################################################################   vinci更新检查脚本源代码   ####################################################################################
############################################################################################################################################################################################
####内容说明：
####1、检查程序的启动方式：1、脚本启动更新；2、脚本返回更新。
####2、当脚本启动更新时，输入值为1.为程序报错或用户报错更新。
####3、当脚本返回更新时，获取返回值1.则为程序报错,要求返回更新检查程序继续更新。2.程序暂无错，用户自主要求返回程序检查更新。
####4、输出返回值：1、退出旧版本；2、要求继续执行旧版本。

####### 基本参数 ######
Ver=3                                   #版本号
def_name="vinci"                        #默认名称
def_path="/usr/local/bin"     #新下载脚本目录路径

####### 下载网址 ######
#Vultr-Debian11.sh文件网址
link_Vultr_Debian11="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh"

####### 颜色
RED='\033[0;31m'
NC='\033[0m'

#######  其他参数  #######
#$cur_path                              为旧脚本目录路径
#$cur_name                              为旧脚名称
#$wrong                                 为错误启动更新模式
def_name=$( [ -z "$cur_name" ] && echo "$def_name" || echo "$cur_name" )                        #脚本名称
file_path=$( [ -z "$cur_path" ] && echo "$def_path/$def_name" || echo "$cur_path/$def_name" )     #文件路径
Version=""                                                                                        #最新版本号

                                  

####### 主函数 ######
function main {
    (( wrong==1 )) || clear
    while true; do
         #如果未获取到新版本文件
        if ! code="$(curl -s "$link_Vultr_Debian11")"; then  
            echo -n "vinci脚本下载失败，请检查网络！即将返回..."
            countdown 10
            exit 2
        fi
        
        #如果脚本已经存在，则开始检查更新。如果脚本不存在，则跳过检查直接开始下载。
        if [ -e "$file_path" ]; then
             #获取新版本号
             Version=$( echo "$code" | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')
             #已下载新版本文件，开始获取旧版本号机代码数量
             cur_Version=$(sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}' "$file_path") 
             num=$(n="$(cat "$file_path")" &&  echo "${#n}")  
             (( wrong==1 )) && warning 
             #如果已是最新版本
             if [ "$code" == "$(cat "$file_path")" ]; then
                  (( wrong==1 )) && continue   #如果是报错更新，现显示错误提醒，并重新检测更新
                  echo "当前已是最新版本V$cur_Version.$num！"
                  exit 2 
             else 
                  (( wrong==1 )) && echo "${RED} 当前脚本运行出现错误！即将开始更新${NC}" 
                       echo "当前版本号为：V$cur_Version.$num"
                       echo "最新版本号为：V$Version.${#code}，即将更新脚本..."
                  ! (( wrong==1 )) && cp -f "$file_path" "$file_path"_backup && echo "已对当前版本进行备份！" 
             fi
         fi 
         #开始下载
         wget --no-cache "$link_Vultr_Debian11" -O  "$file_path"
         chmod +x "$file_path"
         echo "管理系统V"$Version.$(eval echo $num)"版本已下载\更新完成，即将进入系统！"
         countdown 10
         $def_name 2
         wrong=$?
         if [ "$wrong" == "0" ]; then                       #如果脚本正常运行，则退出
              exit 1                                            
         elif [ "$wrong" == "2" ]; then                           #如果用户要求更新，则继续更新
              continue
         else 
              wrong=1
              continue
         fi
    done  
    
}

#######   保存提示  ####### 
 function warning {
      tput sc  #保存当前光标位置
      local t=0
      n=$((n + 1))
      while true; do
            tput rc  #恢复光标位置
            tput el  #清除光标后内容
            t=$((t + 1)); if ((t % 50 == 0)); then break; fi   #每隔50s检查一次更新情况
            [ "$a" == "true" ] && b="              正在等待服务器端版本更新，输入任意键退出...                " || b='                                                                         '
            [ "$a" == "true" ] && a="false" || a="true"
            echo -e "${RED}#########################################################################################${NC}"
            echo -e "${RED}####   脚本运行出现错误！当前运行版本为：V$cur_Version.$num，检查程序版本为：V$Ver,第$n次检查   ####${NC}"
            echo -e "${RED}####$b####${NC}"
            echo -e "${RED}#########################################################################################${NC}"
            read -t 1 -n 1 input  #读取输入，在循环中一次1秒
            if [ -n "$input" ] || [ $? -eq 142 ] ; then
                if bar 15 "已取消继续更新，即将尝试回滚至旧版本" "开始回滚" true "已取消回滚！即将返回..."; then exit 1; fi 
                cp -f "$file_path"_backup "$file_path" 
                echo
                echo "已回滚至旧版本！即将返回..."
                countdown 10
                exit 2   
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
