#!/bin/bash 
#程序组成结构:1、启动程序（即本程序）,用于下载、启动更新update程序和主程序（该两程序及本程序容错率为0）。
#2、update程序，用于更新、加载配置文件。
#3、主程序，诠释程序作用。
setopt interactivecomments
####### 版本更新相关参数 ######
Version=1.00  #版本号 

####### 定义本脚本名称、应用数据路径 ######
def_name="vinci"                                                                         #启动程序脚本默认名称
data_name="$HOME/myfile"                                                                 #应用数据文件夹位置路径                   
data_path="$data_name/${def_name}_src"                                                   #应用数据文件夹位置名
mkdir "$data_name"  >/dev/null 2>&1                                                      #创建文件夹 
mkdir "$data_path"  >/dev/null 2>&1                                                      #应用资源文件夹

#### 配置文件、程序网址、路径 ####
#仓库
link_repositories="https://raw.githubusercontent.com/vincilawyer/Bash/main/"            
#update.src.sh
link_update="${link_repositories}library/update.src.sh"                                  #更新检查程序网址
path_update="$data_path/update.src.sh"                                                   #更新检查程序路径
#main.src.sh
link_main="${link_repositories}vinci/main.src.sh"                                      #主程序网址
path_main="$data_path/main.src.sh"                                                     #主程序路径
#
link_def="${link_repositories}vinci/vinci.sh"                                                  #启动程序下载网址

####### Android系统启动程序网址、路径 ######
      if uname -a | grep -q 'Android'; then echo '检测系统为Android，正在配置中...' 
path_def="/data/data/com.termux/files/usr/bin/$def_name"                                           #启动程序目录路径
        
####### Debian系统启动程序网址、路径 ######
      elif uname -a | grep -q 'Debian'; then echo '检测系统为Debian，正在配置中...'
path_def="/usr/local/bin/$def_name"                                                                #启动程序目录路径

####### Mac系统启动程序网址、路径 ######
      elif uname -a | grep -q 'Darwin'; then echo '检测系统为Mac，正在配置中...'
path_def="/Users/Vinci/Desktop/$def_name"                                                                #启动程序目录路径

###### 其他系统启动程序网址、路径 ######
      else echo '未知系统，正在配置默认版本中...'
path_def="/usr/local/bin/$def_name"                                                                #启动程序目录路径
      fi    

######  退出函数 ######      
function quit() {
local exitnotice="$1"
local scrname="$2"
local funcname1="$3"
local funcname2="$4"
   if [ -n "$exitnotice" ]; then
        echo -e "${RED}出现错误：$exitnotice。错误代码详见以下：${NC}"
        echo -e "${RED}错误函数为：$funcname1${NC}"
        echo -e "${RED}调用函数为：$funcname2${NC}"
        echo -e "${RED}错误模块为：$funcname2${NC}"
   else
        clear
   fi            
   echo -e "${GREED}已退出vinci脚本！${NC}"
   exit
}

#######   当脚本错误退出时，启动更新检查   ####### 
function handle_error() {
    echo "脚本运行出现错误！即将退出"
    countdown 50
}

#######   当脚本退出   ####### 
function normal_exit() { 
:
}

#######   脚本退出前执行  #######   
trap 'handle_error' ERR
trap 'normal_exit' EXIT


#基础更新
function base_update {
echo "正在启动基础更新..."
#下载更新检查程序
if ! curl -H 'Cache-Control: no-cache' -L "$link_update" -o "$path_update" >/dev/null 2>&1 ; then echo "更新检查程序下载失败，请检查网络！"; wait; fi

#载入更新检查文件，并获取错误输出
wrongtext="$(source $path_update 2>&1 >/dev/null)"
if [ -n "$wrongtext" ]; then echo "当前更新检查程序存在语法错误，未能启动主程序，报错内容为：" 
     echo "$wrongtext"
     quit
else
     source "$path_update"
     echo "开始更新检查..."
fi    

#更新本程序
update_load "$path_def" "$link_def" "$def_name脚本" 2 

#更新主程序   
update_load "$path_main" "$link_main" "主程序" 1

}

#开始运行脚本
clear
base_update
main
