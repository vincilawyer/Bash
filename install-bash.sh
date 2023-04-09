#!/bin/bash
if [[ -z $current_Vesion ]]; then
    echo "正在下载Vultr-Debian11脚本"
    wget --no-cache https://raw.githubusercontent.com/vincilawyer/Bash/main/Vultr-Debian11/Vultr-Debian11.sh -O /usr/local/bin/vinci
    chmod +x /usr/local/bin/vinci
    vinci
else
    echo "当前版本号为$current_Vesion"
    Vesion=$(curl -s https://example.com/myscript.sh | grep 'Version=' | cut -d'=' -f2)
    echo "最新版本号为: $Vesion"
fi
    
