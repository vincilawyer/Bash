############################################################################################################################################################################################
##################################################################################   更新检查程序   #######################################################################################
############################################################################################################################################################################################
####内容说明：检查文件更新，载入并判断是否存在语法错误

####### 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

#时间戳，防止缓存
sjc="?timestamp=$(date +%s)"

#######  更新函数  #######
function update_load {
local file_path="$1"                            #为旧脚本目录路径
local file_link="$2"                            #脚本url链接
local file_name="$3"                            #配置文件名称
local loadcode="$4"                             #加载模式，1为source、2为bash
local upcode="${5:-0}"                          #更新模式,0为无需更新，1为正常更新，2为报错更新
local startcode="${5:-0}"                       #更新模式,0为无需更新，1为正常更新,传递给启动程序，使其继续更新
local initial_name="$6"                         #执行初始化函数名
local n=0                                       #错误警告更新次数

echo     
while true; do
    #如果文件不存在
    if ! [ -e "$file_path" ]; then
         #下载更新文件
         echo "正在下载$file_name文件..."
         if ! curl -s -H 'Cache-Control: no-cache' -L "$file_link$sjc" -o "$file_path"; then 
              #如果下载失败
              echo -e "${RED}$file_name文件下载失败，请检查网络！${NC}"
              echo "Wrong url:$file_link"
              echo "${RED}$file_name文件缺失，即将退出系统..." && quit
         fi   
         echo -e -n "${BLUE}$file_name文件已完成下载。${NC}"
         countdown 2 
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
               if ! code="$(curl -s -H 'Cache-Control: no-cache' "$file_link$sjc")"; then    
                    #代码获取失败
                    echo -e "${RED}$file_name文件更新失败，请检查网络！${NC}"
                    echo "Wrong url:$file_link"
                    wait
               else
                   #获取旧版本代码
                   old_code="$(cat "$file_path")"     
                   #如果两版本一致
                   if [[ "$code" == "$old_code" ]]; then 
                         #如果是报错更新，先报错，并继续检测更新
                         if  (( upcode==2 )); then
                             (( ++n )) 
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
   fi

   #开始载入：如果载入模式为source。注：为了防止检验语法时，发生指令滞留，无法退出检测，尽量不要在模块文件中，执行指令。仅定义变量与函数。需要执行的指令，可以定义一个初始化函数来执行
   if (( loadcode == 1 )); then
        echo -e -n "${GREEN}正在载入$file_name文件...${NC}"
        #开始脚本语法检查
        local wrongtext=""
        wrongtext="$(source "$file_path" 2>&1 >/dev/null)"
        if [[ -n "$wrongtext" ]]; then  
             echo "$file_name文件存在语法错误，报错内容为："
             echo "$wrongtext"
             echo "即将开始重新更新"
             upcode=2
             continue
        fi          
        #如果脚本没有语法错误，则载入
        source "$file_path"
        echo -e "${GREEN}载入完成${NC}"
        #执行初始化函数
        if [ -n "$initial_name" ]; then
             echo
             echo -e "${GREEN}开始初始化$file_name模块...${NC}"
             $initial_name
             echo
             echo -e "${GREEN}$file_name初始化完成！${NC}"
        fi
        return
          
   #开始载入：启动程序如果有更新，则开始载入在新的shell环境中载入
   elif (( loadcode == 2 )); then
          echo -n "即将重启程序..."
          countdown 3
          #增加执行权限
          chmod +x "$file_path"
          $file_path "$startcode"
          if [[ "$?" == "2" ]]; then
              echo "$file_name启动脚本存在语法错误，报错内容如上"
              echo "即将开始重新更新"
              upcode=2
              wrongtext=""
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
            [[ "$a" == "true" ]] && b="  正在等待服务器端版本更新，输入任意键退出...   " || b='                                                '
            [[ "$a" == "true" ]] && a="false" || a="true"
            echo -e "${RED}########################################################${NC}"
            echo -e "${RED}########################################################${NC}"
            echo -e "${RED}####                                                ####${NC}"
            echo -e "${RED}####    ${RED}$file_name文件错误！正在进行第$n次检查$ti   ${NC}"
            echo -e "${RED}####                                                ####${NC}"
            echo -e "${RED}####$b####${NC}"
            echo -e "${RED}####                                                ####${NC}"
            echo -e "${RED}########################################################${NC}"
            echo -e "${RED}########################################################${NC}"
            read -t 1 -n 1 input  #读取输入，在循环中一次1秒
            if [[ -n "$input" ]] || [ $? -eq 142 ] ; then
                echo "已取消继续更新${RED}$file_name文件，并退出系统！"
                quit
            fi
      done
}

#######   倒计时  ####### 
function countdown {
    local from=$1
if [[ "$CURSHELL" == *"bash"* ]]; then
    tput sc  # Save the current cursor position
    while (( from >= 0 )); do
        tput rc  # Restore the saved cursor position
        tput el  # Clear from cursor to the end of the line
        printf "%02ds" $from  # Print the countdown
        if $(read -s -t 1 -n 1); then break; fi
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
    
