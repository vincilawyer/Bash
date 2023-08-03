#!/bin/bash 
############################################################################################################################################################################################
##################################################################################   更新检查程序   #######################################################################################
############################################################################################################################################################################################
####内容说明：检查文件更新，载入并判断是否存在语法错误

####### 基本参数 ######
Ver=5                                   #版本号

####### 颜色
RED='\033[0;31m'
NC='\033[0m'


#######  更新函数  #######
function update_load {
local file_path="$1"                            #为旧脚本目录路径
local file_link="$2"                            #脚本url链接
local file_name="$3"                            #配置文件名称
local loadcode="$4"                             #加载模式，1为source、2为bash
local necessary="${5:false}"                    #是否必要，true为必要
local upcode="$6"                               #更新模式
local n="1"                                     #错误警告更新次数

     (( upcode==1 )) || clear
     echo "正在检查$file_name文件更新..."
     
     while true; do
         #开始获取代码
        if ! code="$(curl -s "$file_link")"; then    #如果未获取到代码
            echo -ne "${RED}$file_name文件下载失败，请检查网络！${NC}"
            countdown 10
            [[ $necessary == "true" ]] && ! [ -e "$file_path" ] && echo "即将退出系统..." && exit
            return
        fi
        
        #如果文件存在，则开始检查更新。如果文件不存在，则跳过检查直接开始下载。
        if [ -e "$file_path" ]; then
        
             #已下载新版本文件，开始获取旧版本号及代码字符数量
             cur_Version=$(sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}' "$file_path") 
             num=$(n="$(cat "$file_path")" &&  echo "${#n}") 

             #如果已是最新版本
             if [ "$code" == "$(cat "$file_path")" ]; then
                  (( upcode==1 )) && ( warning "$file_path" "$file_name" "$necessary" "$cur_Version" "$num" "$n"; ((n++)); continue ) #如果是报错更新，现显示错误提醒，并重新检测更新
                  echo "${RED}$file_name文件当前已是最新版本V$cur_Version.$num！"
                  return
                  
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
         echo "$code" > "$file_path"
                  
         #如果载入模式为source
         if (( loadcode == 1 )); then
              echo "${RED}$file_name文件V"$Version.$(eval echo $num)"版本已下载\更新完成，即将继续！"
              countdown 3
              wrongtext=""
              wrongtext="$(source $file_path 2>&1 >/dev/null)"   #载入配置文件，并获取错误输出
              if [ -n "$wrongtext" ]; then  #如果新的配置文件存在错误
              echo "$file_name文件存在语法错误，报错内容为："
              echo "$wrongtext"
              echo "即将重新开始更新"
              upcode=1
              continue
          elif (( loadcode == 2 )); then
              echo "${RED}$file_name文件V"$Version.$(eval echo $num)"版本已下载\更新完成，即将重启系统！"
              countdown 10
              $file_path
              local result="$?"
                  if ((result == 2 )); then        #执行文件语法错误
                      "$file_name文件存在以上语法错误"
                      echo "即将重新开始更新"
                      upcode=1
                      continue
                  fi 
              exit
          elif (( loadcode == 3 )); then
              echo "${RED}$file_name文件V"$Version.$(eval echo $num)"版本已下载\更新完成，即将继续！"
              countdown 3
              return
          fi
          exit
    done  
    
}

#######   保存提示  ####### 
 function warning {
      local file_path="$1"                        
      local file_name="$2"                
      local $necessary="$3"
      local $cur_Version="$4"
      local $num="$5"
      local $n="$6"
      
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
                [[ $necessary == "true" ]] && ! [ -e "$file_path" ] && echo "即将退出系统..." && exit
                return   
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
