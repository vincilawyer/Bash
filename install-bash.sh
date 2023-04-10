#!/bin/bash
if [[ -z $current_Version ]]; then
    echo "正在下载Vultr-Debian11脚本"
    wget --no-cache https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh -O /usr/local/bin/vinci
    chmod +x /usr/local/bin/vinci
    Version=$(cat /usr/local/bin/vinci | grep 'Version=' | cut -d'=' -f2 | head -1)
    if [[ -z $Version ]]; then
      echo "下载失败，请检查网络！"
    else
      echo "管理系统V$Version已下载完成，即将进入系统！"
      sleep 3
      vinci
    fi
else
    #强制更新
    if [ "$current_Version" == "force" ]; then
    
       wget --no-cache https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh -O /usr/local/bin/vinci
       chmod +x /usr/local/bin/vinci
       Version=$(cat /usr/local/bin/vinci | grep 'Version=' | cut -d'=' -f2 | head -1)
       if [[ -z $Version ]]; then
           echo "下载失败，请检查网络！"
           sleep 5
           exit 0
       else
           echo "管理系统V$Version强制更新已完成，即将重启管理系统！"
           sleep 2
           clear
           exit 1
       fi
    #自动检查更新 
    else
        #检查最新版本号
        Version=$(curl -s https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh | grep 'Version=' | cut -d'=' -f2 | head -1)
        #无需更新
        if [[ "${current_Version}" == "${Version}" ]]; then
           echo "当前已是最新版本(V$Version)，无需更新！"
           sleep 2
           exit 0
        #更新至最新版本
        else
           echo "当前版本号为：V${current_Version}"
           wget --no-cache https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh -O /usr/local/bin/vinci
           chmod +x /usr/local/bin/vinci
           echo "已更新至V$Version版本，即将重启管理系统！"
           sleep 4
           clear
           exit 1
        fi
    fi
fi
    
