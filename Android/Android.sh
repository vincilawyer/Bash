#!/bin/bash 
############################################################################################################################################################################################
##############################################################################   vinci脚本源代码   ########################################################################################
############################################################################################################################################################################################
###          目  录        
###   1.参数               
###   2.脚本启动及退出检查模块        
###   3.主函数
###   4.开发工具 
###   5.文本管理模块    
###   6.用户数据及应用配置管理模块       
############################################################################################################################################################################################
############################################################################################################################################################################################
###   说明:
###   一、输入参数：1.则为用户报错更新。2.则本脚本为更新检查程序唤醒。
###   二、输出返回值：1.则为程序报错,要求返回更新检查程序继续更新;2.当脚本出现语法错误，可能返回值为2;3.程序暂无错，用户自主要求返回程序更新。


####### 版本更新相关参数 ######
Version=1.00  #版本号 
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"      #获取当前脚本的目录路径
script_name="$(basename "${BASH_SOURCE[0]}")"                                     #获取当前脚本的名称
file_path="$script_path/$script_name"                                             #获取当前脚本的文件路径
Version1="$Version.$(n="$(cat "$file_path")" &&  echo "${#n}")"                   #脚本完整版本号
startnum="$1"                                                                     #当前脚本的启动指令：1、告知本程序由更新程序唤醒；


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
new_text=""   #inp函数输入的内容

####### 定义路径  ######
#更新检查程序网址
link_update="https://raw.githubusercontent.com/vincilawyer/Bash/main/install-bash.sh"
#用户数据路径
dat_path="/data/data/com.termux/files/home/myfile/vinci.dat"


####### 定义正则表达式 ####### 
#一级域名表达式
domain_regex='^[a-zA-Z0-9-]{1,63}(\.[a-zA-Z]{2,})$'
#二级域名表达式
subdomain_regex='^[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$'
#网址域名
web_regex='^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$'
#邮箱表表达式
email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
#IPV4表达式
ipv4_regex='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
#IPV6表达式
ipv6_regex='^([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])$'
#ip端口号表达式
port_regex='^([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'
#大陆手机11位手机号表达式
tel_regex='^1[3-9]\d{9}$'
#若干#和空格前置的表达式 
comment_regex='^ *[# ]*'

####### 登录logo样式 ####### 
art=$(cat << "EOF"
  __     __         
  \ \   /"/u   
    \ \ / //  
    /\ V /_,-. 
   U  \_/-(_/ 
     // 
    (__) " 

EOF
)

######   配置模板 ######
function pz { echo "$1=\"$(eval echo \$"$1")\"" ; }
function adddat { tn=$#; ([ -z "$1" ] || (( tn > 1 ))) && quit 1 "添加配置模板错误，请检查是否可能遗漏单引号！" || dat_mod+="$1"; }
adddat '
# 该文件为vinci用户配置文本
# * 表示不可在脚本中修改的常量,变量值需要用双引号包围, #@ 用于分隔变量名称、备注、匹配规则（条件规则和比较规则）。比较规则即为正则表达式的变量名，条件规则为判断\$new_text变量是否符合规则条件，条件需用两个\"\"包裹
Dat_num="\"${#dat_mod}\""                         #版本号*              
$(pz "Domain")                                    #@一级域名#@不用加www#@domain_regex
$(pz "Email")                                     #@邮箱#@#@email_regex
' 


#############################################################################################################################################################################################
##############################################################################   2.脚本启动及退出检查模块  ################################################################################################
############################################################################################################################################################################################
###  说明：exit返回值为1，则为程序错误，要求更新检查程序继续更新本脚本。返回值为3，则用户要求更新检查程序继续更新本脚本。

####### 脚本更新  ####### 
#  说明：输入参数为1则为用户报错或程序自检错误更新
function update {
    clear
    if ((startnum == 2)); then exit 3; fi #未出错程序，用户主动要求返回到更新检查程序继续更新 
    cur_path="$script_path" cur_name="$script_name" wrong="$1" bash <(curl -s -L -H 'Cache-Control: no-cache' "$link_update")
    result=$?
    if [ "$result" == "1" ] ; then        #如果已经更新或不需要继续执行
        exit 0   
    elif [ "$result" == "0" ]; then       #如果没有更新(已是最新版、脚本下载失败、新脚本运行错误)，则继续执行当前脚本
        :
    else                                  #如果更新失败，则继续执行当前脚本
        echo -n "未知错误，请检查！即将返回..."
        countdown 5
    fi
} 

#######   倒计时   ####### 
function countdown {
    local from=$1
    tput sc  # Save the current cursor position
    while [ $from -ge 0 ]; do
        tput rc  # Restore the saved cursor position
        tput el  # clear from cursor to the end of the line
        printf "%02ds" $from  # Print the countdown
        if $(read -s -t 1 -n 1); then break; fi
        ((from--))
    done
    echo
}

####### 执行启动前更新检查  ####### 
[ "$startnum" == 2 ] || update $startnum     #刚更新的程序无需再次检查更新

#######  当用户选择主动退出  #########
function quit() {
   if [ "$1" == "0" ]; then
         clear
         echo -e "${GREED}已退出vinci脚本（V"$Version1"）！${NC}"
         exit 0
   elif [ "$1" == "1" ]; then
       echo "$2"
       [ "$startnum" == "2" ] && exit 1              #检查程序更新脚本后的退出（即无需再次启动检查程序），这里的exit不会执行normal_exit函数
       update 1    
   else
       echo -e "${GREED}非正常退出vinci脚本（V"$Version1"）！${NC}";
   fi
}

#######   当脚本错误退出时，启动更新检查   ####### 
function handle_error() {
    echo "脚本运行出现错误！"
   [ "$startnum" == "2" ] && exit 1              #检查程序更新脚本后的退出（即无需再次启动检查程序），这里的exit不会执行normal_exit函数
   update 1                                     #唤醒程序更新
}

#######   当脚本退出   ####### 
function normal_exit() { : ; }

#######   脚本退出前执行  #######   
trap 'handle_error' ERR
trap 'normal_exit' EXIT

#############################################################################################################################################################################################
##############################################################################   3.主函数  ################################################################################################
############################################################################################################################################################################################
#######   主菜单选项  ######
main_menu=(
    "  1、系统设置"              'page true " 系 统 设 置 " "${system_menu[@]}"'
    "  2、工具箱"                'page true " 工 具 箱 " "${toolbox_menu[@]}"'   
    "  3、Docker服务"            'page true "Docker" "${docker_menu[@]}"'
    "  4、Alist服务"            'page true "Alist" "${alist_menu[@]}"'
    "  5、Rclone服务"            'page true "Rclone" "${rclone_menu[@]}"'
    "  0、退出")

ufw_menu=(
    "  1、返回上一级"            "return"
    "  2、启动\重启防火墙"        "restart ufw"
    "  3、启用防火墙规则"         "ufw enable"
    "  4、停用防火墙规则"         "ufw disable"
    "  5、查看防火墙规则"         "ufw status verbose"
    "  6、查看防火墙运行状况"     "status ufw"
    "  7、停止防火墙"            "stop ufw"
    "  0、退出")      
    
function main {

  #判断系统适配  
  if [ ! $(lsb_release -rs) = "11" ]; then 
  echo "请注意，本脚本是适用于Vulre服务器Debian11系统，用于其他系统或版本时将可能出错！"
  wait
  fi
  
  #检查用户数据文件 
  clear
  update_dat 
  
  #显示一级菜单主页面
  page false " 主 菜 单 " "${main_menu[@]}" 
          
}

#############################################################################################################################################################################################
##############################################################################   4.开 发 工 具  ################################################################################################
############################################################################################################################################################################################

######   页面显示   ######
function page {
   local title="$2"    #页面标题
   local waitcon=$1    #确认是否等待
    while true; do
    # 清除和显示页面样式
    clear
    echo; echo -e "${RED}${art}${NC}"; echo; echo; echo "   欢迎进入Vinci服务器管理系统(版本V$Version1)"
    echo; echo "================== "$2" ====================="; echo
    
    array=("${@:3}")
    menu=()
    cmd=()
    
    #分离菜单和指令
    for (( i=0; i<${#array[@]}; i++ )); do
        if (( i % 2 == 0 )) ; then
            menu+=("${array[$i]}")
            echo "${array[$i]}" 
        else
            cmd+=("${array[$i]}")
        fi
    done
    #获取菜单数量
    menunum=${#menu[@]} 
    echo
    echo -n "  请按序号选择操作: "
    inp false 1 '"[[ "$new_text" =~ ^[0-9]+$ ]] && (( $new_text >= 0 && $new_text <= '$((menunum-1))' ))"'
    [ "$new_text" == "0" ] && quit 0              #如果选择零则退出
    clear 
    eval ${cmd[$((new_text-1))]}  || ( echo "指令执行可能失败，请检查！"; waitcon="true" )
    [ "$waitcon" == "true" ] && wait
done

}

###### 查看程序运行状态 ######
function status {
    if [ -n "$1" ]; then
      systemctl status "$1"
      return
    fi

#如果没有指定则按应用列表输出
apps=(
"ufw"
"docker"
"nginx"
"warp-svc"
"tor"
"frps"
)
   for app in "${apps[@]}"; do  
      zl="systemctl status $app"
      i=1
      while IFS= read -r line; do
          if (( "$i" == 1 )); then
              echo -e "${RED}${line}${NC}"
          else
              echo "$line"
          fi
          i=$((i+1))
      done < <($zl)
   done
}

###### 启动、重启程序 ######
function restart {
   echo "正在重启$1..."
   systemctl restart "$1"
}

###### 停运程序 ######
function stop {
   echo "已停止$1运行！"
   systemctl stop "$1"
}

#######  检验程序安装情况   ########
function installed {
    local software_name=$1
    if which "$software_name" >/dev/null 2>&1; then
       echo -e "${GREEN}该程序已经安装，当前版本号为 $($software_name -v 2>&1)${NC}" 
       if confirm "是否需要重新安装或更新？" "已取消安装！"; then return 0; fi
       return 1
    else
      return 1
    fi
}


#######   等待函数   #######   
function wait {
   if [[ -z "$1" ]]; then
    echo "请按下任意键继续"
   else
    echo $1
   fi
   read -n 1 -s input
}
      

#############################################################################################################################################################################################
##############################################################################   5.文本和输入管理模块  ################################################################################################
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
                      if (end == "" ) {
                         print substr($0, startPos + length(start)) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      } else {
                         print substr($0, startPos + length(start), endPos - 1) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      }
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
      }  else {
           print $0;
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
  local comment="${7:-fasle}"     # 是否修改注释行,false模式下，输入#则内容替换为空字符。输入为"#"，则为#
  local is_file="${8:-True}"      # 是否为文件
  local input="$9"                # 要替换的内容
  local mean="${10}"              # 显示搜索和修改内容的含义
  local mark="${11}"              # 修改内容备注
  #          ${@:12}              # 匹配规则，参照inp函数
  local temp_file="$(mktemp)"
  old_text=""                     # 设置搜中的旧文本作为全局变量（不含“注释行”字样）
  new_text=""                     # 设置输入的新文本作为全局变量（不含前后空格）

     old_text1=$(search "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "true" "$is_file" "$input")
     old_text=${old_text1// (注释行)/}
     echo
     echo -e "${BLUE}【"$mean"设置】${NC}${GREEN}当前的"$mean"为$([ -z "$old_text1" ] && echo "空" || echo "：$old_text1")${NC}"
     while true; do
         #-r选项告诉read命令不要对反斜杠进行转义，避免误解用户输入。-e选项启用反向搜索功能，这样用户在输入时可以通过向左箭头键或Ctrl + B键来移动光标并修改输入。
         echo -ne "${GREEN}请设置新的$mean（$( [ -n "$mark" ] && echo "$mark,")输入为空则跳过$( [[ $coment == "true" ]] && echo "，输入#则设为注释行" || echo "，输入#则设为空值" )）：${NC}"
         inp true ${@:12} $( [ -n "${13}" ] && echo "#" )  
         if [[ -z "$new_text" ]]; then
             echo -e "${GREEN}已跳过$mean设置${NC}"
             return 1
         else    
            if  [[ $is_file == "true" ]]; then   #如果在文件模式下
                 if [[ "$new_text" == "#" ]] && [[ $comment == "true" ]]; then
                     replace "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "$comment" "$is_file" "$input" "$new_text"
                     echo -e "${BLUE}已将"$mean"参数设为注释行${NC}"
                     return 0
                 else
                     [[ "$new_text" == "#" ]] && new_text=""
                     [[ "$new_text" == '"#"' ]] && new_text="#"
                     replace  "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "$comment" "$is_file" "$input" "$new_text"
                     echo -e "${BLUE}"$mean"已修改为"$([ -z "$new_text" ] && echo "空" || echo "：$new_text")"${NC}"
                     return 0
                 fi
            else                           #如果在文本模式下

               :
            fi
         fi
     done  
}    

#######   输入框    ####### 
#说明：1、传入的第一个参数为true则能接受回车输入，第一个参数为false则不能回车输入。参数带有""号字符，则将参数视为具体条件语句，没有""则为普通比较。
#     2、传入的第二个参数为比较模式，1为正则表达式匹配，2为字符串普通匹配。两种模式下，都可以使用条件语句。
#     其余参数均为比较参数
function inp {
    tput sc
    local k="true" #判断参数是否全部为空
    while true; do
        new_text=""
        read new_text
        [ $1 = true ] && [[ -z "$new_text" ]] && tput el && return   #如果$1为true，且输入为空，则完成输入
        for Condition in "${@:3}"; do
           #如果参数为空则继续下一个参数
           [[ -z $Condition ]] && continue   
           k="false"
           # 检查参数是否为条件语句
           if [[ "${Condition:0:1}" == '"' && "${Condition: -1}" == '"' ]]; then   #注意-1前面有空格
                if eval ${Condition:1:-1}; then tput el && return; fi
           # 如果参数为普通字符串
           else
               if [ "$2" == "1" ]; then
                  [[  $new_text =~ $Condition ]] && tput el && return
               elif [ "$2" == "2" ]; then
                  [[ "$new_text" == "$Condition" ]] && tput el && return
               fi
           fi
        done
        [ "$k" == "true" ] && tput el && return
        tput rc
        tput el
        echo
        echo -e "${RED} 输入不正确，请重新输入！${NC}"
        tput rc
   done
}

#######  插入文本 ######
function insert {
    local argtext="$1"           # 参数内容
    local config="$2"           # 配置内容
    local location_string="$3"     #匹配的内容
    local file="$4"                #文件位置
    local findloc=0                #文件中是否找到一个带注释符的匹配内容    
    local lineno=0                 #行号
    local lines=()
    while IFS= read -r line;do
         ((lineno++)) #记住行号
         if [[ $line =~ $location_string ]]; then
              #如果行首不是注释符
              if ! [[ $line =~ ^[[:space:]]*# ]]; then
                  # 插入注释符，并插入新字符串到下一行
                  sed -i "${lineno}s/^/#该行系由vinci脚本修改，原内容为： /" "$file"
                  sed -i "${lineno}a\\$config" "$file"
                  sed -i "${lineno}a\\$argtext" "$file"
                  return
                  
              #如果行首是注释符
              else
                  ((findloc==0)) && findloc=$lineno && continue
                  #如果这不是唯一一行的注释符
                  findloc=0
                  break  
              fi
         fi
    done < "$file"    
    if ! ((findloc==0)); then
       sed -i "${findloc}s/^/#该行系由vinci脚本修改，原内容为： /" "$file"
       sed -i "${findloc}a\\$config" "$file"
       sed -i "${findloc}a\\$argtext" "$file"
       return
    fi
    #如果没找到匹配内容或唯一带有注释匹配内容
    sed -i "${lineno}a\\$config" "$file"
    sed -i "${lineno}a\\$argtext" "$file"
}

#######   是否确认框    #######   
function confirm {
   read -p "$1（Y/N）:" confirm1
   if [[ $confirm1 =~ ^[Yy]$ ]]; then 
   return 1
   fi  
   echo $2
   return 0
}

#############################################################################################################################################################################################
##############################################################################   6.用户数据及应用配置管理模块  ################################################################################################
############################################################################################################################################################################################

#######   创建\更新用户配置数据模板    #######
function update_dat { 
    if ! source $dat_path >/dev/null 2>&1; then   #读取用户数据
        echo "系统无用户数据记录。准备新建用户数据..."
        eval dat_all="\"$dat_mod\"" || quit 1 "更新数据配置模板出错"  #更新数据配置模板
        mkdir $HOME/myfile >/dev/null 2>&1
        echo "$dat_all" > "$dat_path"  #写入数据文件
        echo "初始化数据完成"
        wait
    else
        if ! [ "$Dat_num" == "${#dat_mod}" ] ; then
           echo "配置文件更新中..."
           eval dat_all="\"$dat_mod\"" || quit 1  "更新数据配置模板出错" #更新数据配置模板 
           echo "$dat_all" > "$dat_path" #写入数据文件
           echo "更新完成，可在系统设置中修改参数！"
           wait
        fi
    fi
}

#######   修改数据      #######   
function set_dat { 
  #如果指定配置，则指定修改
    if ! [ $# -eq 0 ]; then
         for arg in "$@"; do
             line=$(search "#@" '' "$arg" 1 false false false true "$dat_path" )            
             IFS=$'\n' readarray -t a <<< $(echo "$line" | sed 's/#@/\n/g') # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。这里的IFS不在while循环中执行，所以用readarray -t a 会一行一行地读取输入，并将每行数据保存为数组 a 的一个元素。-t 选项会移除每行数据末尾的换行符。空行也会被读取，并作为数组的一个元素。
             rule="$(echo -e "${a[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"   #去除规则前后的空格
             if [ -z "$rule" ]; then
             :      #如果是空的，则无需进行判断句的判断
             elif ! [[ "${rule:0:1}" == '"' && "${rule: -1}" == '"' ]]; then   #判断rule是正则表达式变量名还是条件语句,如果是正则表达式变量名则转换为条件语句
                 rule="${!rule}" 
             fi 
             settext "\"" "\"" "$arg" 1 true false false true "$dat_path" "${a[0]}" "${a[1]}" 1 "$rule" 
         done         
    else
    
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
         rule="$(echo -e "${a[3]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"   #去除规则前后的空格
         if [ -z "$rule" ]; then   #如果是空的，则无需进行判断句的判断
             :      
         elif ! [[ "${rule:0:1}" == '"' && "${rule: -1}" == '"' ]]; then   #判断rule是正则表达式变量名还是条件语句,如果是正则表达式变量名则转换为条件语句
             rule=${!rule}   
         fi
         settext "${b[0]}=\"" '"' "" 1 true false false true "$dat_path" "${a[1]}" "${a[2]}" 1 "$rule" 
    done
    fi
    source "$dat_path"   #重新载入数据
    echo
    echo "已修改配置完毕！"
}

#######  应用配置更新   #######   
function update_config {
    lines=()
    local ct=0      #已修改配置的数量
    local ft=0      #修改失败的数量
    while IFS= read -r line; do     
         lines+=("$line")    #将每行文本转化为数组     
    done < "$1" 

    for index in "${!lines[@]}"; do   
         line1=${lines[$index]}
         linenum=$((index+1))            #配置行号
         line2=${lines[$linenum]}
         [[ "$line1" == *'#￥#@'* ]] || continue      #如果没有找到参数行，则继续查找
         [[ "$line2" =~ ^[[:space:]]*# ]] && continue      #如果配置行是注释行，则继续查找
         a=()
         IFS=$'\n' readarray -t a <<< $(echo "$line1" | sed 's/#@/\n/g')    # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。
         varname="$(echo -e "${a[4]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"   #去除变量名的前后空格
         echo 
         #如果变量存在
         if [ -v $varname ]; then
            echo "已将配置由：$line2"
            lines[$linenum]=$(replace "${a[2]}" "${a[3]}" "" 1 false false false false "${line2}"  "${!varname}")
            echo -e "更新为：${BLUE}${lines[$linenum]}${NC}"
            echo
            ct=$(( ct + 1 ))
            
         #如果变量不存在
         else
            echo -e "${RED}配置修改失败：$line2${NC}"
            echo -e "${RED}用户数据中未找到${a[1]}的变量名：$varname${NC}"
            echo
            ft=$(( ft + 1 ))
         fi
    done
        if (( ct > 0 )); then
           printf "%s\n" "${lines[@]}" > "$1"
           echo -e "${BLUE}已完成$ct条配置的修改更新${NC}"
           echo -e "${RED}有$ft条配置更新失败${NC}"
           return 0
        else
           echo -e "${RED}配置更新失败，未找到配置行或配置值！${NC}"
           return 1
        fi
} 


#############################################################################################################################################################################################
##############################################################################    7.系统工具  ################################################################################################
############################################################################################################################################################################################
### 菜单选项 ###
system_menu=(
    "  1、返回上一级"                "return"
    "  2、查看所有重要程序运行状态"    "status"
    "  3、本机ip信息"               "ipinfo"
    "  4、修改配置参数"              "set_dat"
    "  5、查看配置参数文件"           "nano /root/myfile/vinci.dat"
    "  6、修改SSH登录端口和登录密码"   "change_ssh_port; change_login_password"
    "  7、更新脚本"                  'update; [ "$?" == "2" ] && echo "当前版本为最新版，无需更新！"'
    "  0、退出" )    

 
    
###### 查看ip信息 ######
function ipinfo {
  echo "本机IP信息："
  hostname -I
  
#代理端口列表
apps=(
"Warp"
"Tor"
)
   echo "网络状况"
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
    if settext "Port " " " "" 1 false false true true $path_ssh "SSH端口" "0-65535" 1 $port_regex; then
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
    if settext "@" "@" "" "" "" "" "" false "@********@" "SSH登录密码" "至少8位" 1 ".{8,}"; then 
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
##############################################################################    8.工具箱  ################################################################################################
############################################################################################################################################################################################
#### 菜单栏 ###
####  配置  ###
webhook='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=615a90ac-4d8a-48f1-b396-1f4bfbc650cd'
toolbox_menu=(
    "  1、返回上一级"      "return"
    "  2、设置微信通知推送" ""
    "  0、退出")   

###### 消息推送 ######
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

#############################################################################################################################################################################################
##############################################################################   9.Docker  ################################################################################################
############################################################################################################################################################################################
###   说明：查看容器docker ps -a；下载镜像 docker pull ；删除镜像 docker rmi ； 运行容器 docker run ；停止容器 docker stop container_id ；删除 docker rm container_id ；恢复容器 docker start container_id
### 菜单栏
docker_menu=(
    "  1、返回上一级"            "return"
    "  2、安装Docker"           "install_Docker"
    "  3、启动\重启Docker"       "restart docker"
    "  4、查看Docker容器"        'echo "Docker容器状况：" && docker ps -a && echo; echo "提示：可使用docker stop 或 docker rm 语句加容器 ID 或者名称来停止容器的运行或者删除容器 "'
    "  5、查看Docker运行状况"     "status docker"
    "  6、停止Docker运行"        "stop docker"
    "  7、删除所有容器"          'confirm "是否删除所有Docker容器？" "已取消删除容器" || ( docker stop $(docker ps -a -q) &&  docker rm $(docker ps -a -q) && echo "已删除所有容器" )'
    "  0、退出")
    
#######  安装Docker及依赖包  #######
function install_Docker {
     installed "docker" && return
    
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
}

  
#############################################################################################################################################################################################
##############################################################################   Alist  ################################################################################################
############################################################################################################################################################################################
### 菜单栏
alist_menu=(
    "  1、返回上一级"            "return"
    "  2、安装\更新Alist"        'pkg upgrade; pkg update; pkg install alist'
    "  3、启动Alist"             'alist server'
    "  4、查看Alist账户密码"       "alist admin"
    "  0、退出")
    
#############################################################################################################################################################################################
##############################################################################   Rclone  ################################################################################################
############################################################################################################################################################################################
### 菜单栏
rclone_menu=(
    "  1、返回上一级"            "return"
    "  2、安装\更新Rclone"      'pkg upgrade; pkg update; pkg install rclone'
    "  3、Rclone配置"            'rclone config'
    "  4、将Baidu网盘书库更新至Onedrive"            'baidutoonebook'
    "  5、将Onedrive书库更新至Baidu网盘"            'onetobaidubook'
    "  6、将Baidu网盘指定文件更新至Onedrive"            'baidutoone'
    "  7、将Onedrive指定文件更新至Baidu网盘"            'onetobaidu'
    "  8、Rclone使用指引"                       'echo "指令指引";echo "列出文件夹: rclone lsd onedrive:";echo "复制文件：rclone copy";echo "同步文件：rclone sync"'
    "  0、退出")
### 配置 ####
bdbook="共享文件夹/法律电子书（持续更新）"   #百度网盘书库位置
onebook="法律书库"   #onedrive书库位置

### 将baidu同步给onedrive ###
function baidutoone {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
   read -p "请输入要同步给Onedrive的Baidu网盘文件夹路径" bdname
   read -p "请输入Onedrive保存位置路径" onename   
   echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdname 文件夹基本信息如下："
   rclone size baidu:$bdname
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onename 文件夹基本信息如下："
   rclone size onedrive:$onename
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync baidu:$bdname --header "Referer:"  --header "User-Agent:pan.baidu.com" onedrive:$onename   #  更改百度网盘的UA，加速作用。 --header "Referer:"  --header "User-Agent:pan.baidu.com"
   echo "同步完成..."
   notifier "baidu to one 已同步完成"
}

### 将onedrive同步给baidu ###
function onetobaidu {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
   read -p "请输入要同步给Baidu网盘的Onedrive文件夹路径" bdname
   read -p "请输入Baidu网盘保存位置路径" onename
     echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdname 文件夹基本信息如下："
   rclone size baidu:$bdname
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onename 文件夹基本信息如下："
   rclone size onedrive:$onename
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync onedrive:$onename baidu:$bdname --header "Referer:"  --header "User-Agent:pan.baidu.com" 
   echo "同步完成..."
   notifier "one to baidu 已同步完成"
}
### 将baidu书库给onedrive ###
function baidutoonebook {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
     echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdbook 文件夹基本信息如下："
   rclone size baidu:$bdbook
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onebook 文件夹基本信息如下："
   rclone size onedrive:$onebook
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync baidu:$bdbook --header "Referer:"  --header "User-Agent:pan.baidu.com" onedrive:$onebook
   echo "同步完成..."
   notifier "baidu to one 已同步完成"
}

### 将onedrive书库给baidu ###
function onetobaidubook {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
   echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdbook 文件夹基本信息如下："
   rclone size baidu:$bdbook
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onebook 文件夹基本信息如下："
   rclone size onedrive:$onebook
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync onedrive:$onebook baidu:$bdbook --header "Referer:"  --header "User-Agent:pan.baidu.com" 
   echo "同步完成..."
   notifier "one to baidu 已同步完成"
}
    
#############################################################################################################################################################################################
##############################################################################   在更新检查及错误检查后，执行主函数  ################################################################################################
############################################################################################################################################################################################
main
