#!/bin/bash 
############################################################################################################################################################################################
##############################################################################   vinci更新检查脚本源代码   ####################################################################################
############################################################################################################################################################################################
####内容说明：
####1、当脚本启动更新时，输入值为1.为程序报错或用户报错更新;2.程序暂无错，用户自主要求返回程序检查更新。
####4、输出返回值：1、；2、。
#######  传递其他参数  #######
#$file_path                             为旧脚本目录路径
#$file_link                             脚本url链接
#$name                                  配置文件名称
#$wrong                                 为错误启动更新模式


####### 基本参数 ######
Ver=5                                   #版本号

####### 颜色
RED='\033[0;31m'
NC='\033[0m'

####### 主函数 ######
function main {
     [ -z "$file_path" ] && Initialvinci   #如果没有任何参数，则执行初始化
     (( wrong==1 )) || clear
     echo "正在检查${RED}$name文件更新..."
     
     while true; do
         #如果未获取到新版本文件
        if ! code="$(curl -s "$file_link")"; then  
            echo -ne "${RED}$name文件下载失败，请检查网络！即将返回...${NC}"
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
                  (( wrong==1 )) && ( warning; continue ) #如果是报错更新，现显示错误提醒，并重新检测更新
                  echo "${RED}$name文件当前已是最新版本V$cur_Version.$num！"
                  exit
                  
             #如果存在更新版本
             else 
                   #获取新版本号
                   Version=$( echo "$code" | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')
                   (( wrong==1 )) && echo "${RED} 当前${RED}$name文件存在错误！即将开始更新${NC}" 
                   echo "${RED}$name文件当前版本号为：V$cur_Version.$num"
                   echo "${RED}$name文件最新版本号为：V$Version.${#code}，即将更新..."
             fi
         fi 
         
         #开始下载
         curl -H 'Cache-Control: no-cache' -L "$file_link" -o "$file_path"
         echo "${RED}$name文件V"$Version.$(eval echo $num)"版本已下载\更新完成，即将返回系统！"
         countdown 10
         exit 
         
         chmod +x "$file_path"
         $def_name 2   
         wrong=$?  #脚本语法错误，返回值可能为2
         n=0
         if [ "$wrong" == "0" ]; then                       #如果脚本正常更新，则退出
              exit 1                                            
         elif [ "$wrong" == "3" ]; then                           #如果用户要求更新，则继续更新
              continue
         else 
              wrong=1
              continue
         fi   
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
            echo -e "${RED}####   脚本运行错误！当前运行版本V$cur_Version.$num，检查程序版本V$Ver，第$n次检查$ti   ####${NC}"
            echo -e "${RED}####                                                                         ####${NC}"
            echo -e "${RED}####$b####${NC}"
            echo -e "${RED}####                                                                         ####${NC}"
            echo -e "${RED}#################################################################################${NC}"
            echo -e "${RED}#################################################################################${NC}"
            read -t 1 -n 1 input  #读取输入，在循环中一次1秒
            if [ -n "$input" ] || [ $? -eq 142 ] ; then
                echo "已取消继续更新..."
                countdown 10
                exit 0   
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

#######   安卓系统初始化  ####### 
function InitialAndroid {

   # 检查是否已安装 wget(跳过)
   if fasle; then   
      echo "wget未安装. 请先选择清华镜像源..."
      sleep 5
      termux-change-repo
      echo "正在更新源"
      pkg upgrade; pkg update
      # 检查openssl是否最新
      INSTALLED_VERSION=$(pkg list-installed openssl | awk 'NR>1 {print $2}')
      AVAILABLE_VERSION=$(pkg list-all openssl | awk 'NR>1 {print $2}')
      echo $INSTALLED_VERSION
      echo $AVAILABLE_VERSION
      if ! [ "$INSTALLED_VERSION" = "$AVAILABLE_VERSION" ]; then
          echo "正在安装\更新 OpenSSL..."
          pkg upgrade; pkg update; pkg install openssl -y
          INSTALLED_VERSION=$(pkg list-installed openssl | awk 'NR>1 {print $2}')
          echo $INSTALLED_VERSION
          rm -rf $PREFIX 
          echo "OpenSSL 更新完成，需要关闭重启终端软件！"
      fi
      echo "正在安装wget..."
      pkg install wget -y
   fi
   
   # 检查是否已安装 ncurses-utils
   if ! command -v tput &> /dev/null; then
      echo "ncurses-utils未安装. Start installing..."
      pkg upgrade; pkg update; pkg install ncurses-utils -y
   fi
}

##### 更新脚本初始化  #######
function  Initialvinci {
####### Android系统基本参数 ######
      if uname -a | grep -q 'Android'; then echo '检测系统为Android，正在配置中...'     
def_path="/data/data/com.termux/files/usr/bin"     #新下载脚本目录路径
file_link="https://raw.githubusercontent.com/vincilawyer/Bash/main/Android/Android.sh"          # vinci脚本下载网址

     InitialAndroid                                                                              #安卓系统初始化
####### Debian系统基本参数 ######
      elif uname -a | grep -q 'Debian'; then echo '检测系统为Debian，正在配置中...'
def_path="/usr/local/bin"     #新下载脚本目录路径
file_link="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh"  

###### 其他系统 ######
      else echo '未知系统，正在配置默认脚本中...'
def_path="/usr/local/bin"     #新下载脚本目录路径
file_link="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh" 
      fi
def_name="vinci"                  #主脚本默认名称
file_path="$def_path/$def_name"   #文件保存路径
name="$def_name脚本"   
}

######  运行主函数  ######
main
