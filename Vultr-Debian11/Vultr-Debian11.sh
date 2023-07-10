#!/bin/bash 
############################################################################################################################################################################################
##############################################################################   vinci脚本源代码   ########################################################################################
############################################################################################################################################################################################
###          目  录        
###   1.参数               
###   2.脚本启动及退出检查模块        
###   3.主函数
###   4.UI模块
###   5.用户数据管理模块     
###   6.开发工具      
###   7.文本管理模块  
###   8.系统工具
###   9.Docker
###   10.Nginx
###   11.Xui
###   12.Cloudflare
###   13.Tor
###   14.Frp
############################################################################################################################################################################################
############################################################################################################################################################################################



####### 版本更新相关参数 ######
Version=2.91  #版本号,不得为空
Dat_Version=0.1 #用户配置模板版本号
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"      #本脚本的运行路径
script_name="$(basename "${BASH_SOURCE[0]}")"                                     #获取当前脚本的名称
startnum="$1"                                                                     #当前脚本的启动方式：由更新程序唤醒（1） 

####### 定义颜色 ######
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BLACK="\033[40m"
NC='\033[0m'

####### 定义全局变量  ######                                  
option=""     #用户选择序号 
old_text=""   #settext函数修改前内容
new_text=""   #settext函数修改后内容

####### 定义路径  ######
#更新检查程序网址
link_update="https://raw.githubusercontent.com/vincilawyer/Bash/main/install-bash.sh"
#用户数据路径
dat_path="/usr/local/bin/vinci.dat"
#ssh配置文件路径(查看配置：nano /etc/ssh/sshd_config)                           
path_ssh="/etc/ssh/sshd_config"
#nginx配置文件网址
link_nginx="https://raw.githubusercontent.com/vincilawyer/Bash/main/nginx/default.conf"
#nginx配置文件路径 (查看配置：nano /etc/nginx/conf.d/default.conf)                      
path_nginx="/etc/nginx/conf.d/default.conf" 
#nginx日志文件路径
log_nginx="/var/log/nginx/access.log"
#nginx 80端口默认服务块文件路径
default_nginx="/etc/nginx/sites-enabled/default"
#tor配置路径 (查看配置：nano /etc/tor/torrc)            
path_tor="/etc/tor/torrc"
#frp配置文件路径（查看配置：nano /etc/frp/frps.ini）  
path_frp="/etc/frp"

####### 定义正则表达式 ####### 
#一级域名表达式
domain_regex="^[a-zA-Z0-9-]{1,63}(\.[a-zA-Z]{2,})$"
#二级域名表达式
subdomain_regex="^[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$"
#邮箱表表达式
email_regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
#IPV4表达式
ipv4_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
#IPV6表达式
ipv6_regex="^([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])$"
#ip端口号表达式
port_regex="^([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
#大陆手机11位手机号表达式
tel_regex="^1[3-9]\d{9}$"
#若干#和空格前置的表达式 
comment_regex="^ *[# ]*"

####### 用户配置模板文本 ####### 
dat_text='# 该文件为vinci用户配置文本
# "*"表示不可在脚本中修改的常量,变量值需要用双引号包围,"#@"用于分隔变量名称、备注、匹配正则表达式。
Dat_Version1="1"              #@版本号*              
Domain="domain.com"           #@一级域名#@不用加www#@domain_regex
Email="email@email.com"       #@邮箱#@#@email_regex
Cloudflare_api_key="abc"      #@Cloudflare Api
Chatgpt_api_key="abc"         #@Chatgpt Api
Warp_port="40000"             #@Warp监听端口
Tor_port="50000"              #@Tor监听端口
'

#############################################################################################################################################################################################
##############################################################################   2.脚本启动及退出检查模块  ################################################################################################
############################################################################################################################################################################################

####### 脚本更新  ####### 
function update {
    wrong_force="$1"   #用户强制更新为1，程序错误自更新为2
    clear && current_Version="$Version" download_path_path="$script_path" name="$script_name" force="$wrong_force" bash <(curl -s -L -H 'Cache-Control: no-cache' "$link_update")
    result=$?
    if [ $result == "1" ] ; then        #如果已经更新
        exit 0  
    elif [ $result == "2" ]; then      #如果没有更新，则继续执行当前脚本
        :
    elif [ $result == "3" ] ; then      #如果脚本下载失败，则继续执行当前脚本   
        echo -n "即将返回..."
        countdown 5
    elif [ $result == "4" ] ; then      #如果新脚本运行错误，则继续执行旧版本   
        echo -n "继续运行旧版本系统"
        countdown 5
    else                                  #如果更新失败，则继续执行当前脚本
        echo -n "更新程序错误，请检查！即将返回..."
        countdown 5
    fi
} 

#######   倒计时   ####### 
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

####### 执行启动前更新检查  ####### 
update

#######  当用户选择主动退出  #########
function quit() {
   clear
   echo -e "${GREED}已退出vinci脚本（V"$Version"）！${NC}" 
   exit 0
}

#######   当脚本错误退出时，启动强制更新   ####### 
function handle_error() {
   [ "$startup" == "1" ] && exit 1              #检查程序更新脚本后的退出（即无需再次启动检查程序），这里的exit不会执行normal_exit函数
   update 2                                     #程序强制更新
   exit 0
}

#######   当脚本退出   ####### 
function normal_exit() {
   exit 0                                  
}

#######   脚本退出前执行  #######   
trap 'handle_error' ERR
trap 'normal_exit' EXIT

#############################################################################################################################################################################################
##############################################################################   3.主函数  ################################################################################################
############################################################################################################################################################################################

function main {
  #######   判断系统适配     #######   
  if [ ! $(lsb_release -rs) = "11" ]; then 
  echo "请注意，本脚本是适用于Vulre服务器Debian11系统，用于其他系统或版本时将可能出错！"
  wait
  fi

  #######   检查用户数据文件  #######   
  if ! source $dat_path; then   #读取用户数据
        echo "未找到配置文件，正在新建数据..."
        creat_dat
        echo "新建完成，请设置配置参数！"
        set_dat
        echo "已完成配置！"
        wait
  elif ! [ $Dat_Version1 == $Dat_Version ] ; then
        echo "配置文件更新中..."
        update_dat
        echo "更新完成，请在设置中修改参数！"
        wait
  fi
  
  while true; do     #显示页面及选项
  #######   主菜单选项  ######
    main_menu=(
    "  1、系统设置"
    "  2、UFW防火墙管理"
    "  3、Docker服务"
    "  4、Nginx服务"
    "  5、X-ui服务"
    "  6、Cloudflare服务"
    "  7、Tor服务"
    "  8、Frp服务"
    "  9、Chatgpt-Docker服务"
    "  0、退出")
    if Option "请选择以下操作选项" false "${main_menu[@]}" ; then continue; fi   #监听输入一级菜单选项，并判断项目内容
    get_option=$option #记住一级选项
    while true; do
          sub_menu=""
          case $get_option in               
1)###### 1、系统设置  ######
    sub_menu=(
    "  1、返回上一级"
    "  2、查看所有重要程序运行状态"
    "  3、本机ip信息"
    "  4、修改配置参数"
    "  5、修改SSH登录端口和登录密码"
    "  6、强制更新脚本"
    "  7、重置配置参数"
    "  0、退出" )
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                      2)status;;
                      3)ipinfo;;
                      4)set_dat;;
                      5)change_ssh_port
                        change_login_password;;
                      6)update 1;;
                      7)if confirm "是否重置默认配置参数？" "已取消重置"; then break; fi
                        echo "默认配置已重置！"
                        creat_dat;;
                  esac;;
                    
2)###### 2、UFW防火墙管理  ###### 
      sub_menu=(
    "  1、返回上一级"
    "  2、启动防火墙"
    "  3、关闭防火墙"
    "  4、查看防火墙规则"
    "  0、退出")                  
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                      2)sudo ufw enable;;
                      3)sudo ufw disable;;
                      4)sudo ufw status verbose;; 
                 esac;;
3) ###### Docker服务  ###### 
    sub_menu=(
    "  1、返回上一级"
    "  2、安装Docker"
    "  3、查看Docker容器"
    "  0、退出")
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                      2)install_Docker;;
                      3)echo "Docker当前运行状况如下：" && docker ps && echo
                        echo "提示：可使用docker stop 或 docker rm 语句加容器 ID 或者名称来停止容器的运行或者删除容器 ";;
                 esac;;
4)####  Nginx选项   ######
   sub_menu=(
    "  1、返回上一级"
    "  2、安装Nginx"
    "  3、设置Nginx配置"
    "  4、重启Nginx"
    "  5、从github下载\更新配置文件"
    "  6、查看Nginx日志"
    "  0、退出")
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                      2)install_Nginx;;
                      3)set_nginx_config;;
                      4)restart "nginx";;
                      5)download_nginx_config;;
                      6)nano /var/log/nginx/access.log;;
                    esac;;
5)###### Xui服务  ######
     sub_menu=(
    "  1、返回上一级"
    "  2、安装\更新Xui面板"
    "  3、进入Xui面板管理（指令:x-ui）"
    "  0、退出" )
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                      2)install_Xui;;
                      3)x-ui;;
                  esac;;
6) ###### Cloudflare服务  ######
    sub_menu=(
    "  1、返回上一级"
    "  2、Cloudflare DNS配置（账户信息在默认配置中设置）"
    "  3、下载Warp"
    "  0、退出")
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                     2)CF_DNS;;
                     3)install_Warp;;
                 esac;; 
7)###### Tor服务 ######
 sub_menu=(
    "  1、返回上一级"
    "  2、安装Tor"
    "  3、设置Tor配置（第一次使用需设置）"
    "  4、重启Tor"
    "  0、退出")
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                      2)install_Tor;;
                      3)set_tor_config;;
                      4)restart "tor"
                        ipinfo "Tor";;
                 esac;; 
         
8)######  Frp服务 ######
    sub_menu=(
    "  1、返回上一级"
    "  2、安装Frp"
    "  3、初始化Frp配置"
    "  4、设置Frp配置"
    "  5、重启Frp"
    "  0、退出")                    
                 if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                 case $option in
                      2)install_Frp;;
                      3)reset_Frp;;
                      4)set_tor_config;;
                      5)restart "frps";;
                 esac;;       
                                                
9)###### Chatgpt ######
   sub_menu=(
    "  1、返回上一级"
    "  2、启动Chatgpt"
    "  3、查看Chatgpt运行状态"
    "  4、Chatgpt更新脚本"
    "  0、退出")                     
                  if Option ${main_menu[$(($get_option - 1))]} "true" "${sub_menu[@]}"; then continue; fi #监听输入二级菜单选项，并判断项目内容
                  case $option in
                       2)echo 1;;
                  esac;; 
            
esac
if [ "$option" == "1" ]; then break; fi  #如果在二级菜单中输出为1，则返回上一级
wait
done    
done   
}
#############################################################################################################################################################################################
##############################################################################   4.UI模块  ################################################################################################
############################################################################################################################################################################################

######   页面显示   ######
function Page {
clear
art=$(cat << "EOF"
  __     __                         _   _           ____                   
  \ \   /"/u          ___          | \ |"|       U /"___|         ___      
    \ \ / //          |_"_|        <|  \| |>      \| | u          |_"_|     
    /\ V /_,-.         | |         U| |\  |u       | |/__          | |      
   U  \_/-(_/        U/| |\u        |_| \_|         \____|       U/| |\u    
     //           .-,_|___|_,-.     ||   \\,-.     _// \\     .-,_|___|_,-. 
    (__)           \_)-' '-(_/      (_")  (_/     (__)(__)     \_)-' '-(_/ 
EOF
)

  echo
  echo -e "${RED}${art}${NC}"
  echo
  echo
  echo "                   欢迎进入Vinci服务器管理系统(版本V$Version)"
  echo
  echo "=========================== "$1" =============================="
  echo 
}

###### 显示和选择选项  ######
function Option {
  Page $1
  #展示选项
  for menu in "${@:3}"   #需要跳过前面2个参数元素
  do 
    echo "$menu"
  done
  echo
  echo -n "  请按序号选择操作: "
  tput sc   # 保存当前光标位置
  #监听输入
while true; do
  read option
  if [ "$option" == "0" ]; then             #如果选择零则退出
      quit      
  elif [ "$option" == "1" ] && [ "$2" == "true" ]; then    #如果二级菜单选择1，则返回上一级
      return 2
  elif [[ "$option" =~ ^[0-9]+$ ]] && (( $option >= 1 && $option <= $(($# - 3)) )); then  #如果选中正确序号（需要减掉本函数前面2个参数数量以及序号0）。
      clear
      return 1
  else
      tput rc  # 回到输入位置
      tput el  # 清空光标后面内容
      echo
      echo -e "${RED}  输入错误，请重新输入${NC}"
      tput rc  # 再次回到输入位置
   fi
done
}


#############################################################################################################################################################################################
##############################################################################   5.用户数据管理模块  ################################################################################################
############################################################################################################################################################################################

#######   创建\重置用户数据   #######
function creat_dat {
    echo "$dat_text" > "$dat_path"
}
#######   用户数据模板更新   #######   
function update_dat {
    lines=()
    while IFS= read -r line; do     
         lines+=("$line")    #将每行文本转化为数组     
    done <<< "$dat_text" 

    for index in "${!lines[@]}"; do   
         line=${lines[$index]}
         if [[ ! $line =~ "=" ]] || [[ $line =~ ^([[:space:]]*[#]+|[#]+) ]] || [[ $line =~ \*([[:space:]]*|$) ]] ; then continue ; fi  #跳过#开头和*结尾的行
         a=()
         IFS=$'\n' readarray -t a <<< $(echo "$line" | sed 's/#@/\n/g')    # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。
         IFS="=" read -ra b <<< "$line" 
         #去除变量名的前后空格
         b[0]="${b[0]#"${b[0]%%[![:space:]]*}"}"  
         b[0]="${b[0]%"${b[0]##*[![:space:]]}"}"
         if [ -z "${!b[0]}" ]; then continue; fi #如果变量不存在，则跳过更新
         lines[$index]=$(replace '"' '"' "" 1 true false false false "$line"  "${!b[0]}")
    done
    printf '%s\n' "${lines[@]}"  > "$dat_path" 
    replace '"' '"' "Dat_Version1" 1 true false false true "$dat_path" "$Dat_Version"  #更新配置版本号
    source "$dat_path"         #重新载入数据
}
#######   修改数据      #######   
function set_dat { 
  if [ -n "$1" ] ; then  #指定修改配置
     line=$(search "#@" "" "$1" 1 true false false true "$dat_path" ) 
     IFS=$'\n' readarray -t a <<< $(echo "$line" | sed 's/#@/\n/g') # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。这里的IFS不在while循环中执行，所以用readarray -t a 会一行一行地读取输入，并将每行数据保存为数组 a 的一个元素。-t 选项会移除每行数据末尾的换行符。空行也会被读取，并作为数组的一个元素。
     #去除正则表达式的前后空格
     a[2]="${a[2]#"${a[2]%%[![:space:]]*}"}"  
     a[2]="${a[2]%"${a[2]##*[![:space:]]}"}"
     settext "\"" "\"" "$1" 1 true false false true "$dat_path" "${a[0]}" "${a[1]}"  "$([ -z "${a[2]}" ] && echo "" || echo "${!a[2]}")"
     return
     #还需手动载入变量
  fi
    
    #如果没有指定配置，则全文修改
    lines=()
    while IFS= read -r line; do   # IFS用于指定分隔符，IFS= read -r line 的含义是：在没有任何字段分隔符的情况下（即将IFS设置为空），读取一整行内容并赋值给变量line。与下面的IFS不同，这个命令在一个 while 循环中执行，每次循环都会读取 line1 中的一行，直到 line1 中的所有行都被读取完毕。
         if [[ ! $line =~ "=" ]] || [[ $line =~ ^([[:space:]]*[#]+|[#]+) ]] || [[ $line =~ \*([[:space:]]*|$) ]] ; then continue ; fi  #跳过#开头和*结尾的行
         lines+=("$line")    #将每行文本转化为数组     
    done < "$dat_path"
    
    # 因为在上面含有IFS= read的循环中，没法再次read到用户的输入数据，因此在循环外处理数据
    for line in "${lines[@]}"; do   
         a=()
         IFS=$'\n' readarray -t a <<< $(echo "$line" | sed 's/#@/\n/g') # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。这里的IFS不在while循环中执行，所以用readarray -t a 会一行一行地读取输入，并将每行数据保存为数组 a 的一个元素。-t 选项会移除每行数据末尾的换行符。空行也会被读取，并作为数组的一个元素。
         IFS="=" read -ra b <<< "$line" 
         #去除正则表达式的前后空格
         a[3]="${a[3]#"${a[3]%%[![:space:]]*}"}"  
         a[3]="${a[3]%"${a[3]##*[![:space:]]}"}"
         settext "${b[0]}=\"" "\"" "" 1 true false false true "$dat_path" "${a[1]}" "${a[2]}"  "$([ -z "${a[3]}" ] && echo "" || echo "${!a[3]}")"
    done
    source "$dat_path"   #重新载入数据
}


#############################################################################################################################################################################################
##############################################################################   6.开 发 工 具  ################################################################################################
############################################################################################################################################################################################

#######  检验程序安装情况   ########
function installed {
    local name=$1
    if [ ! -x "$(command -v $name)" ]; then return 1; fi
    echo -e "${GREEN}该程序已经安装，当前版本号为 $(docker -v 2>&1)${NC}"
    read -p "是否需要重新安装或更新？（Y/N）:" confirm1
    if [[ $confirm1 =~ ^[Yy]$ ]]; then 
       return 1
    fi  
       echo "已取消安装！"
    return 0
}

#######   等待函数   #######   
function wait {
   if [[ -z "$1" ]]; then
    echo "请按下任意键返回"
   else
    echo $1
   fi
   read -n 1 -s input
}

#######   确认函数    #######   
function confirm {
   read -p "$1（Y/N）:" confirm1
   if [[ $confirm1 =~ ^[Yy]$ ]]; then 
   return 1
   fi  
   echo $2
   return 0
}
#############################################################################################################################################################################################
##############################################################################   7.文本管理模块  ################################################################################################
############################################################################################################################################################################################

#######   6.1查询文本内容   #######   
function search {
  local start_string="$1"           # 开始文本字符串
  local end_string="$2"             # 结束文本字符串
  local location_string="$3"        # 定位字符串
  local n="${4:-1}"                 # 要输出的匹配结果的索引
  local exact_match="${5:-True}"    # 是否精确匹配结束文本字符串
  local module="${6:-True}"         # 是否在一段代码内寻找定位字符串，false为行内寻找
  local comment="${7:-True}"        # 是否显示注释行
  local is_file="${8:-True}"        # 是否为文件
  local input="$9"                  # 要搜索的内容
  local found_text=""               # 存储找到的文本
  local count=0                     # 匹配计数器
  
  #定义awk的脚本代码
  local awk_script='{
    if($0 ~ location || (mod && mat) ) {
      mat="true"
      if (exact == "true") {
              startPos = index($0, start);
              if (startPos > 0) {
              endPos = index(substr($0, startPos + length(start)), end);
                  if (endPos > 0) {
                      if (++count == num) {
                          print substr($0, startPos + length(start), endPos - 1) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                          exit;
                      }
                 }
             }  
      } else {
            startPos = index($0, start);
            if (startPos > 0) {
              endPos = index(substr($0, startPos + length(start)), end);
              if (endPos > 0) {
                  if (++count == num) {
                      print substr($0, startPos + length(start), endPos - 1) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      exit;
                  }    
              } else {  
                  if (++count == num) {  # 输出第 n 个匹配结果
                      print substr($0, startPos + length(start)) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      exit;
                                        }
              }
           }  
      }
    }
  }'
  
  if [ "$is_file" = "true" ]; then    #如果输入的是文件
    found_text=$(awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module" -v exact="$exact_match" -v num="$n" "$awk_script" "$input")
  else   #如果输入的是字符串
    found_text=$(echo "$input" | awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module" -v exact="$exact_match" -v num="$n" "$awk_script")
  fi

  if ! $comment; then found_text=${found_text// (注释行)/}; fi
  echo "$found_text"   # 输出找到的文本
}

#######   6.2 替换文本内容   #######   
function replace() {
  local start_string="$1"         # 开始文本字符串
  local end_string="$2"           # 结束文本字符串
  local location_string="$3"      # 定位字符串
  local n="${4:-1}"               # 匹配结果的索引
  local exact_match="${5:-True}"  # 是否精确匹配
  local module="${6:-True}"       # 是否在一段代码内寻找定位字符串，false为行内寻找
  local comment="${7:-fasle}"     # 是否修改注释行
  local is_file="${8:-True}"      # 是否为文件
  local input="$9"                # 要替换的内容
  local input_text="${10}"          # 替换的新文本
  local temp_file="$(mktemp)"
    
  #定义awk的脚本代码
  local awk_script='{
    if($0 ~ location || (mod && mat) ) {
        mat="true"
        if (exact == "true") {
             startPos = index($0, start);
             if (startPos > 0) {
                 endPos = index(substr($0, startPos + length(start)), end);
                  if (endPos > 0) {
                      if (++count == num) {
                          if (comment == "true"  && new == "#" ) {
                              print "#" $0 
                          } else {
                              starttext = substr($0, 1 , startPos - 1 + length(start) );
                              endtext = substr($0, startPos + length(start) + endPos - 1 );
                              line = starttext new endtext;
                              if (comment == "true") {
                                   match(line, /^[ \#]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/\#/, "", s)
                                   line = s substr(line, RLENGTH + 1)
                              }
                              print line;
                          }
                      } else {
                       print $0;
                      }
                  } else {
                       print $0;
                  }
             } else {
                 print $0;
             }
        } else {
             startPos = index($0, start);
             if (startPos > 0) {
                 endPos = index(substr($0, startPos + length(start)), end);
                  if (endPos > 0) {
                      if (++count == num) {
                          if (comment == "true"  && new == "#" ) {
                              print "#" $0 
                          } else {
                              starttext = substr($0, 1 , startPos - 1 + length(start) );
                              endtext = substr($0, startPos + length(start) + endPos - 1 );
                              line = starttext new endtext;
                              if (comment == "true") {
                                   match(line, /^[ \#]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/\#/, "", s)
                                   line = s substr(line, RLENGTH + 1)
                              }
                              print line;
                          }
                      } else {
                       print $0;
                      }
                  } else {
                      if (++count == num) {
                          if (comment == "true"  && new == "#" ) {
                              print "#" $0 
                          } else {
                              starttext = substr($0, 1 , startPos - 1 + length(start) );
                              line = starttext new;
                              if (comment == "true") {
                                   match(line, /^[ \#]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/\#/, "", s)
                                   line = s substr(line, RLENGTH + 1)
                              }
                              print line;
                          }                      
                      } else {
                       print $0;
                      }
                  }
             } else {
                 print $0;
             }        
        }  
      } 
    }'

  if [ "$is_file" = "true" ]; then    #如果输入的是文件
      awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module" -v exact="$exact_match" -v new="$input_text" -v comment="$comment" -v num="$n" "$awk_script" "$input" > "$temp_file"
      mv "$temp_file" "$input"
  else   #如果输入的是字符串
      temp_text=$(echo "$input" | awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module"  -v exact="$exact_match" -v new="$input_text" -v comment="$comment" -v num="$n" "$awk_script")
      echo "$temp_text"   # 输出替换的内容
  fi
}  

#######   6.3修改文本对话框   #######   
function settext {
  local start_string="$1"         # 开始文本字符串
  local end_string="$2"           # 结束文本字符串
  local location_string="$3"      # 定位字符串
  local n="${4:-1}"               # 匹配结果的索引            
  local exact_match="${5:-True}"  # 是否精确匹配结束文本字符串
  local module="${6:-True}"       # 是否在一段代码内寻找定位字符串，false为行内寻找
  local comment="${7:-fasle}"     # 是否修改注释行
  local is_file="${8:-True}"      # 是否为文件
  local input="$9"                # 要替换的内容
  local mean="${10}"              # 显示搜索和修改内容的含义
  local mark="${11}"              # 修改内容备注
  local regex="${12}"             # 正则表达式
  local regex1="${13:-fasle}"     # 内容与正则表达式的真假匹配
  local temp_file="$(mktemp)"
  old_text=""                     # 设置搜中的旧文本作为全局变量（不含“注释行”字样）
  new_text=""                     # 设置输入的新文本作为全局变量（不含前后空格）
  
     old_text1=$(search "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "true" "$is_file" "$input")
     old_text=${old_text1// (注释行)/}
     echo
     echo -e "${GREEN}【修改"$mean"】当前的"$mean"为："$old_text1"${NC}"
     while true; do
         #-r选项告诉read命令不要对反斜杠进行转义，避免误解用户输入。-e选项启用反向搜索功能，这样用户在输入时可以通过向左箭头键或Ctrl + B键来移动光标并修改输入。
         read -r -e -p "$(echo -e ${GREEN}"请设置新的"$mean"（$( [ -n "$mark" ] && echo "$mark,")输入为空则跳过$( [[ $coment == "true" ]] && echo "，输入#则设为注释行")）：${NC}")" new_text
         #s/^[[:space:]]*//表示将输入字符串中开头的任何空格字符替换为空字符串；s/[[:space:]]*$//表示将输入字符串结尾的任何空格字符替换为空字符串。
         new_text="$(echo -e "${new_text}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
         if [[ -z "$new_text" ]]; then
             printf "\033[K%s"  # 清除当前行的文本
             echo -e "${GREEN}已跳过$mean设置${NC}"
             return 1
         else    
            if  [[ $is_file == "true" ]]; then   #如果在文件模式下
                 if [[ "$new_text" == "#" ]] && [[ $comment == "true" ]]; then
                     replace "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "$comment" "$is_file" "$input" "$new_text"
                     printf "\033[K%s"  # 清除当前行的文本
                     echo -e "${BLUE}已将"$mean"参数设为注释行${NC}"
                     return 0
                 elif [[ "$new_text" =~ $regex ]]; then
                     replace  "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "$comment" "$is_file" "$input" "$new_text"
                     printf "\033[K%s"  # 清除当前行的文本
                     echo -e "${BLUE}"$mean"已修改为"$new_text"${NC}"
                     return 0
                 else
                     echo -e "${RED}输入的"$mean"不符合要求，请重新输入！${NC}"
                     printf "\033[2A\033[K%s"
                 fi
            else                           #如果在文本模式下
                 if [[ "$new_text" =~ $regex ]]; then
                 printf "\033[K%s"  # 清除当前行的文本
                 return 0
                 else
                 echo -e "${RED}输入的"$mean"不符合要求，请重新输入！${NC}"
                 printf "\033[2A\033[K%s"
                 fi
            fi
         fi
     done  
}

#############################################################################################################################################################################################
##############################################################################   8.系 统 工 具  ################################################################################################
############################################################################################################################################################################################

###### 查看程序运行状态 ######
function status {

#应用列表
apps=(
"ufw"
"warp-svc"
"tor"
)
   for app in "${apps[@]}"; do  
      cmd="systemctl status $app"
      i=1
      while IFS= read -r line; do
          if (( "$i" == 1 )); then
              echo -e "${RED}${line}${NC}"
          else
              echo "$line"
          fi
          i=$((i+1))
      done < <($cmd)
   done
}
###### 查看ip信息 ######
function ipinfo {
  echo "本机IP信息："
  hostname -I
  
#代理端口列表
apps=(
"Warp"
"Tor"
)
   echo "代理IP信息："
   for app in "${apps[@]}"; do  
       port_value=$(eval echo \$"${app}_port")
       echo "$app(端口$port_value)的代理IP地址为："
       curl --socks5-hostname localhost:"$port_value" http://api.ipify.org
      echo
   done

}

#######  修改SSH端口    #######  
function change_ssh_port {
    if settext "Port " " " "" 1 false false true true $path_ssh "SSH端口" "0-65535，" $port_regex; then
          echo -e "${GREEN}已正从防火墙规则中删除原SSH端口号：$old_text${NC}"
          ufw delete allow $old_text/tcp   
          echo -e "${GREEN}正在将新端口"$new_text"添加进防火墙规则中。${NC}"
          ufw allow "$new_text"/tcp  
          systemctl restart sshd
          echo -e "${GREEN}当前防火墙运行规则及状态为：${NC}"
          ufw status
    fi  
}

#######  修改登录密码    ####### 
function change_login_password {
    # 询问账户密码 
    if settext "@" "@" "" "" "" "" "" false "@********@" "SSH登录密码" "至少8位" ".{8,}"; then 
         #修改账户密码
         chpasswd_output=$(echo "root:$new_text" | chpasswd 2>&1)
         if echo "$chpasswd_output" | grep -q "BAD PASSWORD" >/dev/null 2>&1; then
            echo -e "${RED}SSH登录密码修改失败,错误原因：${NC}"
            echo "$chpasswd_output" >&2
         else
            echo -e "${GREEN}SSH登录密码已修改成功！新密码为:$new_text,请妥善保管！${NC}"
         fi
   fi
}
#############################################################################################################################################################################################
##############################################################################   9.Docker  ################################################################################################
############################################################################################################################################################################################

#######  安装Docker及依赖包  #######
function install_Docker {
    if installed "docker" ;then return; fi  #检验安装
    
    # 安装docker，具体在https://docs.docker.com/engine/install/debian/中查看说明教程
    # 卸载冲突包
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
    
    # 更新apt包索引并安装包以允许apt通过 HTTPS 使用存储库：
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg

    #添加Docker官方GPG密钥：
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    #使用以下命令设置存储库：
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    #更新apt包索引：
    sudo apt-get update
    #安装最新版本 Docker 引擎、containerd 和 Docker Compose。
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    #通过运行镜像来验证Docker Engine安装是否成功。
    if docker run hello-world; then echo "Docker安装成功！" ; fi
}

#############################################################################################################################################################################################
##############################################################################   10.Nginx模块  ################################################################################################
############################################################################################################################################################################################


####### 安装Nginx ######
function install_Nginx {
        installed "nginx" && return    #检验安装
        echo -e "${GREEN}正在更新包列表${NC}"
        apt-get update
        echo -e "${GREEN}包列表更新完成${NC}"
        apt-get install nginx -y
        echo -e "${GREEN}Nginx 安装完成，版本号为 $(nginx -v 2>&1)。${NC}"
        echo -e "${GREEN}正在调整防火墙规则，放开80、443端口。${NC}"
        ufw allow http && ufw allow https 
        echo -e "${GREEN}正在调整Nginx配置${NC}"
        download_nginx_config
        echo "" > $default_nginx   # 清空nginx对80端口默认服务块的配置内容

}

####### 从github下载更新Nginx配置文件 ####### 
function download_nginx_config {
      if confirm "是否从Github下载更新Nginx配置文件？此举动将覆盖原配置文件" "已取消下载更新Nginx配置文件"; then return; fi
      echo -e "${GREEN}正在载入：${NC}"
      if wget $link_nginx -O $path_nginx; then 
         echo -e "${GREEN}载入完毕，第一次使用请设置配置：${NC}"
        set_nginx_config
    else
            echo -e "${GREEN}下载失败，请检查！${NC}"
         fi       
}

####### 设置Nginx配置 ####### 
function set_nginx_config {
     echo "维护中，请手动导入配置！"
     return
       if ! [ -x "$(command -v nginx)" ]; then
          echo -e "${RED}Nginx尚未安装，请先进行安装！${NC}"
       fi
       current_domain=$(search "server_name " ";" 1 $path_nginx true false)
       set "ssl_certificate " "/$current_domain" 1 $path_nginx true "SSL证书存放路径"
       current_ssl_path=$(search "ssl_certificate " "$current_domain" 1 $path_nginx true false)
       if set "server_name " ";" 1 $path_nginx true "VPS域名" "" true "^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$"; then
           replace  "$current_ssl_path" ".cer;" 1 "$text2" $path_nginx true
           replace  "$current_ssl_path" ".key;" 1 "$text2" $path_nginx true
       fi
       if set "https://" "; #伪装网址" 1 $path_nginx true "伪装域名" "" true "^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$"; then
           replace  "sub_filter \"" "\"" 1 "$text2" $path_nginx true
           replace  "proxy_set_header Host \"" "\"" 1 "$text2" $path_nginx true
       fi
       set "location /ray-" " {" 1 $path_nginx true "xray分流路径" "省略/ray-前缀，"
       set "http://127.0.0.1:" "; #Xray端口" 1 $path_nginx true "Xray监听端口" "0-65535，" true "^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
       set "location /xui-" " {" 1 $path_nginx true "x-ui面板分流路径" "省略/xui-前缀，"
       set "http://127.0.0.1:" "; #xui端口" 1 $path_nginx true "X-ui监听端口" "0-65535，" true "^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
       echo "正在重启Nginx..."
       if nginx -t &> /dev/null; then
          systemctl restart nginx
          return
       fi
       echo "Nginx配置文件存在错误，请检查并修改后重启！"
}   
####### 从github下载网页文件 ####### 
function download_html {
   echo "维护中..."
   return
   if confirm "此操作将从Github的vincilawyer/Bash/nginx/html目录下载入网页文件，并覆盖原网页文件！" "已取消下载更新网页文件"; then return; fi
    #输入主题名称
    read -p "请输入网页主题名称（例如Moon）：" input
    if [[ -z $input ]]; then 
        echo "已取消操作!"
        return
    fi
    echo "正在下载网页zip压缩包..."

    #开始下载并覆盖
    if wget "$link_html$input".zip -O /home/"$input".zip; then
       echo "压缩包下载完成，开始解压"
       unzip /home/"$input".zip -d /home
       path_html=$(search "root" " ")
       echo "开始覆盖原网页文件"
       rm -r "$path_html"/*  >/dev/null
       mv /home/"$input"/* "$path_html"/
       echo "已更新网页文件！"
       rm -r /home/"$input".zip
       rm -r /home/"$input"
       rm -rf /home/__MACOSX >/dev/null
       echo "已清除压缩包！"
   else
       echo "下载失败，请检查文件名称或网络！"
   fi    
}

                                                                         
#######  使用Certbot申请SSL证书的函数 ####### 
function apply_ssl_certificate {
   echo "维护中"
   return
    # 输入域名
    while true; do
        read -p "$(echo -e ${BLUE}"请输入申请SSL证书域名（不加www.）: ${NC}")" domain_name
        if [[ -z $domain_name ]]; then
          echo -e "${RED}未输入域名，退出申请操作${NC}"
          return
        elif [[ $domain_name =~ ^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo -e "${RED}输入格式不正确，请重新输入${NC}"
        fi
    done

    # 输入邮箱
    while true; do
        read -p "$(echo -e ${BLUE}"请输入申请SSL证书邮箱: ${NC}")" email
        if [[ -z $email || ! $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo -e "${RED}输入格式不正确，请重新输入${NC}"
        else
            break
        fi
    done
    
  
    # 停止nginx运行
    if [ -x "$(command -v nginx)" ]; then
       systemctl stop nginx
       echo -e "${GREEN}为了防止80端口被占用，已停止nginx运行${NC}"
    fi  
  
    #关闭防火墙
    ufw disable 
    echo -e "${GREEN}为了防止证书申请失败，已关闭防火墙${NC}"

    # 检查并安装Certbot
    if [ -x "$(command -v certbot)" ]; then
      echo -e "${GREEN}本机已安装Certbot，无需重复安装，即将申请SSL证书...${NC}"
    else
      echo -e "${GREEN}正在更新包列表${NC}"
      sudo apt update
      echo -e "${GREEN}包列表更新完成${NC}"
      echo -e "${GREEN}正在安装Certbot...${NC}"
      apt install certbot certbot -y
      echo -e "${GREEN}Certbot安装完成，即将申请SSL证书...${NC}"
    fi
  
    # 申请证书
    certbot certonly --standalone --agree-tos -n -d $domain_name -m $email
    
    # 判断申请结果
    if check_ssl_certificate "$domain_name"; then
        echo -e "${GREEN}SSL证书申请已完成！${NC}"
        # 证书自动续约
        echo "0 0 1 */2 * service nginx stop; certbot renew; service nginx start;" | crontab
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}未成功启动证书自动续约${NC}"
        else
            echo -e "${GREEN}已启动证书自动续约${NC}"
        fi
    else
        echo -e "${RED}SSL证书申请失败！${NC}"
    fi
    
    # 重启nginx
    if [ -x "$(command -v nginx)" ]; then
       echo -e "${GREEN}正常恢复nginx运行${NC}"  
       systemctl start nginx
    fi  

    #重启防火墙
    echo -e "${GREEN}正在恢复防火墙运行${NC}"  
    ufw --force enable
}

#######  判断Certbot申请的SSL证书是否存在  ####### 
function check_ssl_certificate {
   echo "维护中"
   return
    domain_name="$1"
    ssl_path="$2"
    #搜索SSL证书
    search_result=$(find "$2/" -name fullchain.pem -print0 | xargs -0 grep -l "$domain_name" 2>/dev/null)
    if [[ -z "$search_result" ]]; then
      return false
    else
      return true
    fi
}

      
#############################################################################################################################################################################################
##############################################################################   11.Xui模块  ################################################################################################
############################################################################################################################################################################################

###### 安装X-ui的函数 ######
function install_Xui {
   if installed "x-ui"; then return; fi
        bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

#############################################################################################################################################################################################
##############################################################################   12.Cloudflare模块  ################################################################################################
############################################################################################################################################################################################

###### Cf dns配置 ######
function CF_DNS {
   while true; do 
   # 获取区域标识符
   zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain" \
     -H "X-Auth-Email: $Email" \
     -H "X-Auth-Key: $Cloudflare_api_key" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')
     
   if [ "$zone_identifier" == "null" ]; then
       echo "未找到您的Cloudflare账户\域名，请检查配置。"
       set_dat "Domain"
       return
   fi
    get_all_dns_records $zone_identifier
    # 询问用户要进行的操作
    echo "操作选项："
    echo "1. 删除DNS记录"
    echo "2. 修改或增加DNS记录"
    echo "3、www域名一键绑定本机ip（开启CDN）"
    read -p "请选择要进行的操作：" choice
    case $choice in
      1)
        # 删除DNS记录
        clear
        get_all_dns_records $zone_identifier
        read -p "请输入要删除的DNS记录名称（例如 www）：" record_name

        # 获取记录标识符
        record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name.$Domain" \
             -H "X-Auth-Email: $Email" \
             -H "X-Auth-Key: $Cloudflare_api_key" \
             -H "Content-Type: application/json" | jq -r '.result[0].id')
        
        clear
        # 如果记录标识符为空，则表示未找到该记录
        if [ "$record_identifier" == "null" ]; then
            echo "未找到该DNS记录。"
        else
            # 删除记录
            curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                 -H "X-Auth-Email: $Email" \
                 -H "X-Auth-Key: $Cloudflare_api_key" \
                 -H "Content-Type: application/json"
            echo
            echo "已成功删除DNS记录: $record_name.$Domain"
            echo
            get_all_dns_records $zone_identifier
        fi;;
    2)# 修改或增加DNS记录
        clear
        get_all_dns_records $zone_identifier
        read -p "请输入要修改或增加的DNS记录名称（例如 www）：" record_name
        while true; do
            read -p "请输入IP地址：" record_content
            if [[ $record_content =~ $ipv4_regex ]]; then
                break
            else
                echo "无效的IP地址，请重试。"
            fi
        done
        read -p "是否启用Cloudflare CDN代理？（Y/N）" enable_proxy
        if [[ $enable_proxy =~ ^[Yy]$ ]]; then
            proxy="true"
        else
            proxy="false"
        fi

            # 获取记录标识符
            record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name.$Domain" \
                 -H "X-Auth-Email: $Email" \
                 -H "X-Auth-Key: $Cloudflare_api_key" \
                 -H "Content-Type: application/json" | jq -r '.result[0].id')
            clear 
            # 如果记录标识符为空，则创建新记录
            if [ "$record_identifier" == "null" ]; then
                curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
                     -H "X-Auth-Email: $Email" \
                     -H "X-Auth-Key: $Cloudflare_api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo
                echo "已成功添加记录 $record_name.$Domain"
                echo
                get_all_dns_records $zone_identifier
            else
                # 如果记录标识符不为空，则更新现有记录
                curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $Email" \
                     -H "X-Auth-Key: $Cloudflare_api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo
                echo "已成功更新记录 $record_name.$Domain"
                echo
                get_all_dns_records $zone_identifier
           fi;;
     3)
          record_name="www"
          record_content=$(ip addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)
          proxy="true"
           # 获取记录标识符
            record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name.$Domain" \
                 -H "X-Auth-Email: $Email" \
                 -H "X-Auth-Key: $Cloudflare_api_key" \
                 -H "Content-Type: application/json" | jq -r '.result[0].id')
            clear 
            # 如果记录标识符为空，则创建新记录
            if [ "$record_identifier" == "null" ]; then
                curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
                     -H "X-Auth-Email: $Email" \
                     -H "X-Auth-Key: $Cloudflare_api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo
                echo "已成功添加记录 $record_name.$domain"
                echo
                get_all_dns_records $zone_identifier
            else
                # 如果记录标识符不为空，则更新现有记录
                curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $Email" \
                     -H "X-Auth-Key: $Cloudflare_api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo
                echo "已成功更新记录 $record_name.$Domain"
                echo
                get_all_dns_records $zone_identifier
           fi;;    
    *) echo "输入错误，已取消操作！";;
  esac
  wait
  done
}
######  获取并显示所有DNS解析记录、CDN代理状态和TTL  ######
function get_all_dns_records {
    dns_records=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$1/dns_records?type=A" \
         -H "X-Auth-Email: $Email" \
         -H "X-Auth-Key: $Cloudflare_api_key" \
         -H "Content-Type: application/json" | jq -r '.result[] | [.name, .content, .proxied, .ttl] | @tsv')
       echo "——————————DNS解析编辑器v2————————————"
       echo "以下为$Domain域名当前的所有DNS解析记录："
       echo
       echo "域名                      ip        CDN状态      TTL"
       echo "$dns_records"
       echo
       echo
}


###### 安装cf warp套 ######
function install_Warp {

    if installed "warp-cli"; then return; fi
        #先安装WARP仓库GPG密钥：
        echo -e "${GREEN}正在安装WARP仓库GPG 密钥${NC}"
        curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        #添加WARP源：
        echo -e "${GREEN}正在添加WARP源${NC}"
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        #更新源
        echo -e "${GREEN}正在更新包列表${NC}"
        sudo apt update
        #安装Warp
        echo -e "${GREEN}开始安装Warp${NC}"
        apt install cloudflare-warp -y
        #注册WARP：
        echo -e "${GREEN}注册WARP中，请输入y予以确认${NC}"
        warp-cli register
        #设置为代理模式（一定要先设置）：
        echo -e "${GREEN}设置代理模式${NC}"
        warp-cli set-mode proxy
        #连接WARP：
        echo -e "${GREEN}连接WARP${NC}"
        warp-cli connect
        sleep 2
        #查询代理后的IP地址：
        echo -e "${GREEN}Warp 安装完成，代理IP地址为：${NC}"
        curl ifconfig.me --proxy socks5://127.0.0.1:40000
        echo
}

#############################################################################################################################################################################################
##############################################################################   13.Tor模块  ################################################################################################
############################################################################################################################################################################################


                                                                          # 安装Tor的函数
function install_Tor {
   if [ -x "$(command -v tor)" ]; then
        echo -e "${GREEN}Tor已安装，无需重复安装！${NC}"      
   else
        echo -e "${GREEN}正在更新包列表${NC}"
        sudo apt update
        echo -e "${GREEN}开始安装Tor${NC}"
        apt install tor -y
   fi
}

                                                                     
                                                                     # 安装Warp并启动Warp的函数

                                                                           # 设置Tor配置
function set_tor_config {
   settext "SocksPort " " " "" 2 false false "true" "true" $path_tor "Tor监听端口" "0-65535，" $port_regex
}
                                                                           # 获取Tor ip
function ip_tor {
  old_text=$(search "SocksPort " " " "" 2 "false" "false" "false" "true" $path_tor )
  echo "当前Tor代理IP为："
  curl --socks5-hostname localhost:$old_text http://ip-api.com/line/?fields=status,country,regionName,city,query
  echo
}
  
  
                                                                          # 安装Frp的函数
function install_Frp {
   if [ -x "$(command -v frps)" ]; then 
        echo -e "${GREEN}Frp已安装，无需重复安装！${NC}"   
   else
        # 获取最新的 frp 版本
        version=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep 'tag_name' | cut -d\" -f4)
        # 获取Linux amd64版本的tar.gz文件名
        file_name=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | jq -r '.assets[] | select(.name | contains("linux_amd64")) | .name')
        # 下载最新版本的 frp
        wget https://github.com/fatedier/frp/releases/download/$version/$file_name
        # 解压下载的文件
        tar -xvzf $file_name
        rm $file_name
        
        # 把frps加入systemd
        mv $(echo $file_name | sed 's/.tar.gz//')/frps /usr/bin/
        mkdir -p $path_frp
        mv $(echo $file_name | sed 's/.tar.gz//')/frps.ini $path_frp
        rm -r $(echo $file_name | sed 's/.tar.gz//')
        cat > /usr/lib/systemd/system/frps.service <<EOF
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frps -c /etc/frp/frps.ini

[Install]
WantedBy=multi-user.target
EOF
   fi
}
function reset_Frp {
if confirm "是否重置Frp配置" "已取消重置！"; then return; fi 
cat > $path_frp/frps.ini <<EOF
[common]
# 服务端监听端口
bind_port = 8888
# HTTP 类型代理监听的端口（给Nginx反向代理用）
vhost_http_port = 10080
vhost_https_port = 10443
# 鉴权使用的 token 值
token = 88888888
#服务端仪表板端口
dashboard_port = 21211
#仪表板登录用户名
dashboard_user = admin
#仪表板登录密码
dashboard_pwd = admin
EOF
}



                                                                          # 安装CF_DNS的函数
function install_CF_DNS {
    if confirm "是否从Github下载更新CF_DNS脚本文件？此举动将覆盖原脚本文件。" "已取消下载更新CF_DNS脚本文件"; then return; fi
    #安装jq
    echo "正在安装依赖软件JQ..."
    if [ -x "$(command -v jq)" ]; then
        echo -e "${GREEN}JQ已安装，无需重复安装！${NC}"      
    else
        apt update
        apt install jq -y
    fi
    echo -e "${GREEN}正在下载CF_DNS脚本文件：${NC}"
    wget $link_cfdns -O $path_cfdns
    chmod +x $path_cfdns 

}
                                                                          # 修改CF_DNS配置的函数
function set_CF_config {
#维护中
    if ! [ -e "$path_cfdns" ]; then
        echo "CF_DNS脚本尚未安装，请先安装！"
        return
    fi
    set 'email="' '"' 1 $path_cfdns "true" "true" "Cloudfare账户邮箱" "" true "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    set 'domain="' '"' 1 $path_cfdns true "Cloudfare绑定域名" "不加www等前缀，" true "^[a-z0-9]+(-[a-z0-9]+)*\.[a-z]{2,}$"
    set 'api_key="' '"' 1 $path_cfdns true "Cloudfare API密钥"
    chmod +x $path_cfdns
}


                                                                          # 一键搭建服务端的函数
function one_step {
   if confirm "是否一键搭建科学上网服务端？" "已取消一键搭建科学上网服务端"; then return; fi
   echo "正在安装X-ui面板"
   install_Xui
   wait "点击任意键安装Nginx"
   install_Nginx
   wait "点击任意键安装Warp"
   install_Warp
   echo "请：
   1、在x-ui中自行申请SSL
   2、在x-ui面板中调整xray模板、面板设置，并创建节点"
}
function restart {
   echo "正在重启$1..."
   systemctl restart "$1"
}

#############################################################################################################################################################################################
##############################################################################   在更新检查及错误检查后，执行主函数  ################################################################################################
############################################################################################################################################################################################
main
