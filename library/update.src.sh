############################################################################################################################################################################################
##################################################################################   更新检查程序   #######################################################################################
############################################################################################################################################################################################
####内容说明：检查文件更新，载入并判断是否存在语法错误

####### 颜色
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


#######  更新函数  #######
function update_load {
local file_path="$1"                            #为旧脚本目录路径
local file_link="$2"                            #脚本url链接
local file_name="$3"                            #配置文件名称
local loadcode="$4"                             #加载模式，1为source、2为bash
local upcode="${5:-0}"                          #更新模式,0为无需更新，1为正常更新，2为报错更新
local starcode="${5:-0}"                        #更新模式,0为无需更新，1为正常更新,传递给启动程序，使其继续更新
local n=0                                       #错误警告更新次数

     
while true; do
    #如果文件不存在
    if ! [ -e "$file_path" ]; then
         #下载更新文件
         echo "正在下载$file_name文件..."
         if ! curl -H 'Cache-Control: no-cache' -L "$file_link" -o "$file_path"; then 
              #如果下载失败
              echo -e "${RED}$file_name文件下载失败，请检查网络！${NC}"
              echo "Wrong url:$file_link"
              echo "${RED}$file_name文件缺失，即将退出系统..." && quit
         fi   
         echo -e "${BLUE}$file_name文件已完成下载。${NC}"
         countdown 2
         countdown 
    #如果文件已存在     
    else
         #如果无需更新
         if ((upcode==0)); then               
             #如果为主程序，则跳过；其他配置需加载
             (( loadcode == 2 )) && return 
         #如果需要更新，则检查更新
         else
               echo "正在检查$file_name文件更新..."
               #获取代码
               if ! code="$(curl -s "$file_link")"; then    
                    #代码获取失败
                    echo -e "${RED}$file_name文件更新失败，请检查网络！${NC}"
                    echo "Wrong url:$file_link"
                    wait
               fi
               #获取旧版本代码
               old_code="$(cat "$file_path")"     
               #如果两版本一致
               if [[ "$code" == "$old_code" ]]; then 
                     #如果是报错更新，先报错，并继续检测更新
                     if  (( upcode==2 )); then
                         ((n++)) 
                         warning "$file_path" "$file_name" "$necessary" "$cur_Version" "$n"
                         continue
                     fi
                     #无需更新
                     echo -e "${BLUE}$file_name文件当前已是最新版本V${#old_code}！${NC}"
                     #如果是启动程序，则无需载入
                     (( loadcode == 2 )) && return 
                         
                #如果版本不一致,载入新版本
                else
                    (( upcode==2 )) && echo -e "${RED} 当前${RED}$file_name文件存在错误！即将开始更新${NC}" 
                    echo -e "${RED}$file_name文件当前版本号为：V${#old_code}${NC}"
                    printf "%s" "$code" > "$file_path" && chmod +x "$file_path"
                    echo -e "${BLUE}$file_name文件最新版本号为：V${#code}，已完成更新。${NC}"
                fi
         fi
   fi
         

    #开始载入：如果载入模式为source
    if (( loadcode == 1 )); then
          echo -e "${BLUE}正在载入$file_name文件...${NC}"
          
          #脚本语法检查
          wrongtext=""
          wrongtext="$(source "$file_path" 2>&1 >/dev/null)"
          if [ -n "$wrongtext" ]; then  
               #如果新的配置文件存在错误
               echo "$file_name文件存在语法错误，报错内容为："
               echo "$wrongtext"
               echo "即将开始重新更新"
               upcode=2
               continue
               
          #语法无错，正式载入
          else
               source "$file_path"
               return
          fi
          
     #如果有更新，则开始载入在新的shell环境中载入
     elif (( loadcode == 2 )); then
          echo "正在重启程序..."
          #增加执行权限
          chmod +x "$file_path"
          $file_path "$starcode"
          local result="$?"
               if ((result == 2 )); then        #执行文件语法错误
                    echo "$file_name文件存在以上语法错误"
                    echo "即将重新开始更新"
                    upcode=2
                    continue
               fi 
               exit
     fi
done      
}

#######   保存提示  ####### 
 function warning {
      local file_path="$1"                        
      local file_name="$2"                
      local necessary="$3"
      local cur_Version="$4"
      local n="$5"
      
      check_time=35    #检查更新时长
      tput sc  #保存当前光标位置
      local t=0
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
            echo -e "${RED}                  ${RED}$file_name文件错误！正在进行第$n次检查$ti              ${NC}"
            echo -e "${RED}####                                                                         ####${NC}"
            echo -e "${RED}####$b####${NC}"
            echo -e "${RED}####                                                                         ####${NC}"
            echo -e "${RED}#################################################################################${NC}"
            echo -e "${RED}#################################################################################${NC}"
            read -t 1 -n 1 input  #读取输入，在循环中一次1秒
            if [ -n "$input" ] || [ $? -eq 142 ] ; then
                echo "已取消继续更新${RED}$file_name文件，并退出系统！"
                quit
            fi
      done
}

#######   倒计时  ####### 
function countdown {
    local from=$1
if [[ $SHELL == *"bash"* ]]; then
    tput sc  # Save the current cursor position
    while [ $from -ge 0 ]; do
        tput rc  # Restore the saved cursor position
        tput el  # Clear from cursor to the end of the line
        printf "%02ds" $from  # Print the countdown
        if $(read -s -t 1 -n 1); then break; fi
        ((from--))
   done
elif [[ $SHELL == *"zsh"* ]]; then
    echoti sc  # Save the current cursor position
    while (( from >= 0 )); do
        echoti rc  # Restore the saved cursor position
        echoti el  # Clear from cursor to the end of the line
        printf "%02ds" $from  # Print the countdown
        if read -sk -t1; then break; fi
        ((from--))
    done
fi
    echo
}

#######   等待函数   #######   
function wait {
    if [[ -z "$1" ]]; then
        echo "请按下任意键继续"
    else
        echo $1
    fi
    if [[ $SHELL == *"bash"* ]]; then
        read -n 1 -s input
    elif [[ $SHELL == *"zsh"* ]]; then
        stty -echo
        read -k 1 input
        stty echo
    fi
}
