#!/bin/bash #################################################################################################################################################################################
##############################################################################   vinci更新检查脚本源代码   ########################################################################################
############################################################################################################################################################################################

####### 基本参数 ######
Ver=008       #检查脚本版本号
name="vinci"  #脚本名称
#$current_Version 为当前版本号，由运行本脚本时传递该变量
#$force           为是否强制更新，true为强制更新，由运行本脚本时传递该变量

####### 路径 ######
#Vultr-Debian11.sh文件网址
link_Vultr_Debian11="https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh"
#脚本保存路径
download_path="/usr/local/bin"

####### 主函数 ######
function main {
clear
#检查最新版本号
echo "正在检查最新版本($Ver)..."
Version=$(curl -s $link_Vultr_Debian11 | sed -n '/^Version=/ {s/[^0-9.]*\([0-9.]*\).*/\1/; p; q}')
        
#下载脚本请求
if [[ -z $current_Version ]]; then
    echo "正在下载Vultr-Debian11脚本..."
    download "Linux管理系统V"$Version"版本已下载完成，即将进入系统！"   
    exit
#强制更新
elif [ "$force" == "true" ]; then
    echo "当前版本号为：V${current_Version}"
    echo "最新版本号为：V${Version}，即将强制更新脚本..."
    download "Linux管理系统V"$Version"版本已强制更新完成，即将重启管理系统！"

#已是最新
elif [[ "${current_Version}" == "${Version}" ]]; then
    echo "当前已是最新版本(V$Version)，无需更新！"
    exit 0
#正常更新
else 
    echo "当前版本号为：V${current_Version}"
    echo "最新版本号为：V${Version}，即将更新脚本..."
    download "Linux管理系统V"$Version"版本已更新完成，即将进入系统！"
fi
  }
  
####### 下载vinci脚本 ###### 
function download {
    if wget --no-cache "$link_Vultr_Debian11" -O $download_path/"$name" ; then
        chmod +x $download_path/$name
        echo "$1"
        vinci
    else
        echo "下载失败，请检查网络！"
        sleep 3
        exit
    fi    
} 







main
