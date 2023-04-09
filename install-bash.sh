#!/bin/bash
if [[ -z $current_Version ]]; then
    echo "正在下载Vultr-Debian11脚本"
    wget --no-cache https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh -O /usr/local/bin/vinci
    chmod +x /usr/local/bin/vinci
    vinci
else
    if [ "$current_Version" = force ]; then
       wget --no-cache https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh -O /usr/local/bin/vinci
       chmod +x /usr/local/bin/vinci
       echo "强制更新已完成！"
    fi
    Version=$(curl -s https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh | grep 'Version=' | cut -d'=' -f2)
    if [ "$current_Version" = "$Version" ]; then
       echo "当前已是最新版本，无需更新！"
    else
       wget --no-cache https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh -O /usr/local/bin/vinci
       chmod +x /usr/local/bin/vinci
       echo "更新已完成！"
    fi

fi
    
