#!/bin/bash
############################################################################################################################################################################################
##############################################################################   启动程序源代码   ########################################################################################
############################################################################################################################################################################################
#程序组成结构:1、启动程序（即本程序）,用于下载、更新、启动主程序（本程序容错率为0）。
#2、主程序，承担程序功能作用。
#程序启动逻辑：
#1、判断当前运行的系统环境，并对shell环境、网络环境、依赖软件进行适配；
#2、在特定条件下对包括主程序在内的所有程序进行更新，并加载所有配置文件
#3、启动main主程序
############################################################################################################################################################################################
##############################################################################   shell调整环境   ########################################################################################
############################################################################################################################################################################################
#mac系统转为zsh环境。注意，请网站中启动脚本，执行exec语句，新环境将从fi后面的内容开始执行。本地环境执行执行exec语句，新环境将从头开始再次执行本脚本。
if uname -a | grep -q 'Darwin'; then
    [[ $(ps -p $$ -o comm=) == *"bash"* ]] && exec "/bin/zsh" "$0" "$1"
fi

############################################################################################################################################################################################
##################################################################################  基本变量   ###########################################################################################
############################################################################################################################################################################################
####### 版本更新相关参数 ######
Version=2.00 
name_sh="vinci"        
startcode="$1"    #更新指令

####### 定义本脚本名称、应用数据路径 ######
path_user="$HOME/myfile"
path_dir="$path_user/${name_sh}_src"        #应用数据文件夹位置名  
path_data="$path_user/data"                   
path_list="$path_data/srclist.dat"        #组件清单存放位置
path_dat="$path_data/$name_sh.dat"        #配置数据文件路径  
path_log="$path_data/vinci.log"           #日志  （日志格式建议 echo -n "[程序名] " ; date +"%m/%d %H:%M" | tr -d '\n' ; echo "任务名 执行结果如下：" ）         
mkdir -p "$path_dir"                      #创建应用代码文件夹                               
mkdir -p "$path_data"                     #创建应用数据文件夹                                                   

#### 配置文件、程序网址、路径 ####
[ -z "$mainname" ] && source $path_dat &> /dev/null 
#主文件名称
mainname=${mainname:-main}
#仓库-下载链接
link_repositories="https://raw.githubusercontent.com/vincilawyer/My-Shell-Script/main"            
#仓库-文件信息链接
link_reposinfo="https://api.github.com/repos/vincilawyer/My-Shell-Script/contents"                                
#main.src文件下载链接及存放位置                                
path_main="$path_dir/$mainname.src"     
link_main="$link_repositories/$mainname.src"                                     
#vinci.sh启动程序下载链接
link_sh="$link_repositories/vinci.sh" 

####### 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC="${NC:-\033[0m}"

###### 其他
path_vimEnv="$HOME/.vimrc"        #vim配置位置

############################################################################################################################################################################################
##############################################################################   不同系统配置及变量   ########################################################################################
############################################################################################################################################################################################
#在bash中$0为脚本自身路径、可能$SHELL为脚本自身运行环境；但在zsh中$ZSH_ARGZERO为脚本自身路径、可能$(ps -p $$ -o comm=)为脚本自身运行环境
clear
####### Debian系统启动程序网址、路径 ######
if uname -a | grep -q 'Debian'; then 
    path_sh="/usr/local/bin/$name_sh"       #脚本存放位置
    path_nonloginEnv="$HOME/.bashrc"        #终端配置位置
    path_loginpageEnv="/etc/motd"           #登录页面配置位置
    
    CURSHELL="bash"
    echo "检测系统为Debian，当前Shell环境为$SHELL，正在配置中..."

    # 安装依赖件jq
    which "jq" >/dev/null || (echo "正在安装依赖软件JQ..."; apt update; apt install jq -y; echo "依赖件JQ已安装完成！")
    
####### Android Termius系统启动程序网址、路径 ######
elif uname -a | grep -q 'Android'; then 
    path_sh="/data/data/com.termux/files/usr/bin/$name_sh"  #脚本存放位置
    path_nonloginEnv="$HOME/.bashrc"                        #终端配置位置
    
    CURSHELL="bash"
    echo "检测系统为Android，当前Shell环境为$SHELL，正在配置中..."
   
    # 安装依赖件 ncurses-utils，以支持tput工具
    which "tput" >/dev/null || (echo "正在更新系统软件"; rm -rf $PREFIX/etc/apt/sources.list.d/game.list; \
    rm -rf $PREFIX/etc/apt/sources.list.d/science.list; echo "deb https://packages.termux.org/apt/termux-main stable main" > $PREFIX/etc/apt/sources.list; \
    apt update; apt upgrade -y; apt install which ncurses-utils jq -y; echo "系统软件已更新完成并已安装依赖件Which、ncurses-utils、JQ！")
    
    # 安装依赖件jq
    #which "jq" >/dev/null || (echo "正在安装依赖软件JQ..."; apt install jq -y; echo "依赖件JQ已安装完成！")
                                                                
####### Mac系统启动程序网址、路径 ######
elif uname -a | grep -q 'Darwin'; then 
    path_sh="/usr/local/bin/$name_sh"    #脚本存放位置
    path_nonloginEnv="$HOME/.zshrc"      #终端配置位置    
    
    CURSHELL="zsh"
    echo "检测系统为Mac，已切换Shell环境为$(ps -p $$ -o comm=)，正在配置中..."
    #允许注释与代码同行
    setopt interactivecomments
    #让数组编号与bash一致，从0开始
    setopt ksh_arrays
    #打开终端网络代理
    export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;export ALL_PROXY=socks5://127.0.0.1:1086

    
###### 其他系统启动程序网址、路径 ######
else 
    CURSHELL="bash"
    echo "未知系统，当前Shell环境为$SHELL，正在配置默认版本中..."
    echo "未知系统"
    sleep 5
fi  


############################################################################################################################################################################################
##############################################################################   脚本退出及错误检测   ########################################################################################
############################################################################################################################################################################################
######  退出函数 ######      
function quit() {
   local exitnotice="$1"
   if [[ "$exitnotice" == "1" ]]; then
        clear
   elif [[ -n "$exitnotice" ]]; then
            echo -e "${RED}出现错误：$exitnotice。错误代码详见以下：${NC}"
            echo -e "${RED}错误函数为：${FUNCNAME[1]}${NC}"
            echo -e "${RED}调用函数为：${FUNCNAME[2]}${NC}"
            echo -e "${RED}错误模块为：${BASH_SOURCE[1]}${NC}"
   fi            
   echo -e "${GREED}已退出vinci脚本！${NC}"
   exit
}

#######   当脚本错误退出时，启动更新检查   ####### 
function handle_error() {
    echo "脚本运行出现错误！"
    echo -e "${RED}错误代码详见以下：${NC}"
    echo -e "${RED}错误函数为：${FUNCNAME[1]}${NC}"
    echo -e "${RED}调用函数为：${FUNCNAME[2]}${NC}"
    echo -e "${RED}错误模块为：${BASH_SOURCE[1]}${NC}"
    quit
}

#######   当脚本退出   ####### 
function normal_exit() { 
:
}

#######   脚本退出前执行  #######   
trap 'handle_error' ERR
trap 'normal_exit' EXIT

############################################################################################################################################################################################
##################################################################################   更新函数    ###########################################################################################
############################################################################################################################################################################################
function update_load {
###参数###
local path_file="$1"                            #为本地文件目录路径
local link_file="$2"                            #新文件网络url链接
local name_file="$3"                            #配置文件名称
local loadcode="$4"                             #加载模式，1为source、2为bash
local upcode="${5:-0}"                          #更新模式,0为无需更新，1为正常更新，2为报错更新
local startcode="${5:-0}"                       #更新模式,0为无需更新，1为正常更新,传递给启动程序，使其继续更新
local initial_name="$6"                         #执行初始化函数名
local n=0                                       #错误警告更新次数

###开始下载比对###
echo     
while true; do
    #如果本地文件不存在
    if ! [ -e "$path_file" ]; then
         #下载更新文件
         echo -n "正在下载$name_file文件..."
         if ! curl -s "$link_file" -o "$path_file" 2>&1 >/dev/null ; then 
              #如果下载失败
              echo -e "${RED}$name_file文件下载失败，请检查网络！（ URL为:$link_file ）${NC}"
              quit "$name_file文件缺失"
         fi   
         echo -ne "${BLUE}已下载完成。${NC}"
         countdown 1
    #如果本地文件已存在     
    else
         #如果无需更新
         if ((upcode==0)); then               
             #如果为主程序，则跳过；其他配置需加载
             (( loadcode == 2 )) && return 
         #如果需要更新，则检查更新
         else
               echo -ne "\r正在检查$name_file文件更新..."
               
               #获取代码
               if ! code="$(curl -s "$link_file")"; then    
                    #代码获取失败
                    echo -e "${RED}$name_file文件更新失败，请检查网络！${NC}"
                    echo "Wrong url:$link_file"
                    wait
               else
                   #获取旧版本代码
                   old_code="$(cat "$path_file")"     
                   #如果两版本一致
                   if [[ "$code" == "$old_code" ]]; then 
                         #如果是报错更新，先报错，并继续检测更新
                         if  (( upcode==2 )); then
                             (( ++n )) 
                             warning "$path_file" "$name_file" "$necessary" "$cur_Version" "$n"
                             continue
                         fi
                         #无需更新
                         echo -e "${BLUE}当前已是最新版V${#old_code}！${NC}"
                         #如果是启动程序，则无需载入
                         (( loadcode == 2 )) && return 
                         
                    #如果版本不一致,载入新版本
                    else
                        echo
                        (( upcode==2 )) && echo -e "${RED} 当前${RED}$name_file文件存在错误！即将开始更新${NC}" 
                        echo -e "${RED}$name_file文件当前版本号为：V${#old_code}${NC}"
                        printf "%s" "$code" > "$path_file" && chmod +x "$path_file"
                        echo -e "${BLUE}$name_file文件最新版本号为：V${#code}，已完成更新。${NC}"
                    fi
                fi
         fi   #判断更新模式
   fi  #判断文件存在情况

###开始载入##
   #：如果载入模式为source。注：为了防止检验语法时，发生指令滞留，无法退出检测，尽量不要在模块文件中，执行指令。仅定义变量与函数。需要执行的指令，可以定义一个初始化函数来执行
   if (( loadcode == 1 )); then
        echo -e -n "${GREEN}正在载入$name_file文件...${NC}"
        #开始脚本语法检查
        local wrongtext=""
        wrongtext="$(source "$path_file" 2>&1 >/dev/null)"
        if [[ -n "$wrongtext" ]]; then  
             echo -e "\n${RED}$name_file文件存在语法错误，报错内容为：${NC}"
             echo "$wrongtext"
             wait
             echo "即将开始重新更新"
             upcode=2
             continue
        fi          
        #如果脚本没有语法错误，则载入
        source "$path_file"
        echo -e "${BLUE}载入完成${NC}"
        #执行初始化函数
        if [ -n "$initial_name" ]; then
             echo
             echo -e "${BLUE}#### 开始初始化$name_file模块${NC}"
             $initial_name
             echo
             echo -e "${BLUE}####  $name_file初始化完成！  ${NC}"
        fi
        return
          
   #开始载入：启动程序如果有更新，则开始载入在新的shell环境中载入
   elif (( loadcode == 2 )); then
          echo "即将重启程序..."
          #增加执行权限
          chmod +x "$path_file"
          $path_file "$startcode"
          if [[ "$?" == "2" ]]; then
              echo "$name_file启动脚本存在错误，报错内容如上"
              wait
              echo "即将开始重新更新"
              upcode=2
              wrongtext=""
              continue
          fi
          exit
   fi
done      
}

############################################################################################################################################################################################
##################################################################################   其他依赖函数    ###########################################################################################
############################################################################################################################################################################################
#######   报错提示  ####### 
 function warning {
      local file_path="$1"                        
      local file_name="$2"                
      local necessary="$3"
      local cur_Version="$4"
      local n="$5"
      
      check_time=59    #检查更新时长
      tput sc  #保存当前光标位置
      local t=0
      while true; do
            tput rc  #恢复光标位置
            tput el  #清除光标后内容
            t=$((t + 1)); if ((t > $check_time)); then break; fi   #每隔周期检查一次更新情况
            ti=$((( $((check_time-t)) > 9 )) && echo "$((check_time-t))" || echo "0$((check_time-t))")s
            [[ "$a" == "true" ]] && b="  正在等待服务器端版本更新，输入任意键退出...   " || b='                                                '
            [[ "$a" == "true" ]] && a="false" || a="true"
            echo 
            echo -e "${RED}########################################################${NC}"
            echo -e "${RED}########################################################${NC}"
            echo -e "${RED}####                                                ####${NC}"
            echo -e "${RED}####    ${RED}$name_file文件错误！正在进行第$n次检查$ti   ${NC}"
            echo -e "${RED}####                                                ####${NC}"
            echo -e "${RED}####$b####${NC}"
            echo -e "${RED}####                                                ####${NC}"
            echo -e "${RED}########################################################${NC}"
            echo -e "${RED}########################################################${NC}"
            read -t 1 -n 1 input  #读取输入，在循环中一次1秒
            if [[ -n "$input" ]] || [ $? -eq 142 ] ; then
                echo -e "${RED}已取消继续更新$name_file文件，并退出系统！${NC}"
                quit
            fi
      done
}


#######   倒计时   ####### 
function countdown {
    local from=$1
if [[ "$CURSHELL" == *"bash"* ]]; then
    tput sc  # Save the current cursor position
    while (( from >= 0 )); do
        tput rc  # Restore the saved cursor position
        tput el  # Clear from cursor to the end of the line
        printf "%02ds" $from  # Print the countdown
        (( from == 0 )) || { if $(read -s -t 1 -n 1); then break; fi }
        ((from--))
    done
    tput el
    echo
elif [[ "$CURSHELL" == *"zsh"* ]]; then
    echoti sc  # Save the current cursor position
    while (( from >= 0 )); do
        echoti rc  # Restore the saved cursor position
        echoti el  # Clear from cursor to the end of the line
        printf "%02ds" $from  # Print the countdown
        stty -echo   #关闭输入显示
        if read -t 1 -k 1 input; then stty echo;break; fi
        stty echo    #打开输入显示
        from=$(( from-1 ))
    done
    echoti el
    echo
fi    
}

#######   等待函数   #######   
function wait {
    if [[ -z "$1" ]]; then
        echo -e "\n请按下任意键继续"
    else
        echo "请查看wait函数，看看是谁调用的：${FUNCNAME[1]}"
    fi
    
    if [[ "$CURSHELL" == *"bash"* ]]; then
        read -n 1 -s input
    elif [[ "$CURSHELL" == *"zsh"* ]]; then
        stty -echo
        read -k 1 input
        stty echo
    fi
}

#######   定义获取组件清单函数   #######   
function getsrclist { 
     echo "正在载入/更新$1组件清单..."
     local getlist="$(curl -s "$link_reposinfo"/"$1" )"
     [ $? -eq 0 ] || quit "未能获取组件清单，请检查网络!( URL地址：$link_reposinfo/$1 )" 
     (echo "$getlist" | jq '[.[] | {name:.name,download_url:.download_url}]' >> "$path_list") || \
     (echo "$getlist" | jq '[{name:.name,download_url:.download_url}]' >> "$path_list") || \
     quit "组件清单不存在，请检查!( URL地址：$link_reposinfo/$1 )"
}

####错误检测(开发过程使用)###
function check {
    (( ++n ))
    echo "第$n次检测"
    echo "检测函数:${FUNCNAME[1]}"
    echo "检测位置:${BASH_SOURCE[1]}"
    echo "检测内容如下："
#############################################
echo 启动码 $startcode，$1
echo 路径1：$0 
echo 路径2：$ZSH_NAME，$ZSH_ARGZERO
echo 环境1：$(ps -p $$ -o comm=)  
echo 环境2：$SHELL
#############################################
wait
}

############################################################################################################################################################################################
##############################################################################   开始运行   ########################################################################################
############################################################################################################################################################################################
#######   更新本程序、载入主程序   #######   
function base_load {

      #检测代码是在$PATH中直接运行还是通过网络或其他方式启动,非$PATH直接启动则为更新模式
      [[ "$0" == "$path_sh" ]] || [[ "$ZSH_ARGZERO" == "$path_sh" ]] || startcode=1

      #更新本程序
      update_load "$path_sh" "$link_sh" "$name_sh启动" 2 "$startcode"
    
      #更新主程序   
      update_load "$path_main" "$link_main" "主程序" 1 "$startcode" "main_initial"

      if (( startcode == 1 )); then echo -en "${BLUE}\n更新检查完成，即将进入程序...${NC}"; countdown 5; fi

}
base_load
main
