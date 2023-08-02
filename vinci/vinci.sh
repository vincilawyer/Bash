#!/bin/bash 
####### 版本更新相关参数 ######
Version=1.00  #版本号 

####### Android系统基本参数 ######
      if uname -a | grep -q 'Android'; then echo '检测系统为Android，正在配置中...' 
def_path="/data/data/com.termux/files/usr/bin"                                           #主脚本目录路径
main_link="https://raw.githubusercontent.com/vincilawyer/Bash/main/Android/Android.sh"   #脚本下载网址
         
####### Debian系统基本参数 ######
      elif uname -a | grep -q 'Debian'; then echo '检测系统为Debian，正在配置中...'
def_path="/usr/local/bin"                                                                #主脚本目录路径
main_link="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh"  

###### 其他系统 ######
      else echo '未知系统，正在配置默认脚本中...'
def_path="/usr/local/bin"                                                                #主脚本目录路径
main_link="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh" 
      fi
      
####### 定义路径及文件名  ######
link_update="https://raw.githubusercontent.com/vincilawyer/Bash/main/install-bash.sh"    #更新检查程序网址
def_name="vinci"                                                                         #主脚本默认名称
data_name="$HOME/myfile"                                                                 #应用数据文件夹位置路径                   
data_path="$data_name/vinci_source"                                                      #应用数据文件夹位置名
main_path="$def_path/$def_name"                                                          #主脚本保存路径
mkdir "$HOME/myfile"  >/dev/null 2>&1                                                    #创建文件夹 
mkdir "$data_name/${def_name}_src"  >/dev/null 2>&1                                      #应用资源文件夹

function update_load {
    local upcode="$1"                     #更新模式，1为报错模式
    local file_path="$2"                  #更新文件路径
    local file_link="$3"                  #更新文件链接
    local file_name="$4"                  #更新文件名称
    while true; do
       upcode="$upcode" file_path="$file_path" file_link="$file_link" file_name="$file_name" bash <(curl -s -L -H 'Cache-Control: no-cache' "$link_update")       
       local wrongtext="$(source $file_path 2>&1 >/dev/null)"   #载入配置文件，并获取错误输出
       if [ -n "$wrongtext" ]; then  #如果新的配置文件存在错误
          echo "$file_name文件存在语法错误，报错内容为："
          echo "$wrongtext"
          echo "即将重新开始更新"
          upcode=1
          continue
       fi
    done
}  



function InitialAndroid {
   # 检查是否已安装 ncurses-utils
   if ! command -v tput &> /dev/null; then
      echo "ncurses-utils未安装. Start installing..."
      pkg upgrade; pkg update; pkg install ncurses-utils -y
   fi
}
