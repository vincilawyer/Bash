############################################################################################################################################################################################
##############################################################################   vinci脚本主程序源代码   ########################################################################################
############################################################################################################################################################################################
function get_appmanage_menu {
appmanage_menu=(
    "启动/重启$1"                "restart $1"
    "查看$1运行状态"                 "status $1"
    "停止运行$1"                    "stop $1"
    "卸载$1"                    'echo "暂不支持"'
    )    
}   

###### 启动、重启程序 ######
function restart {
   echo "正在重启$1..."
   systemctl restart "$1" && echo "$1已完成重启！"
}

###### 查看程序状况 ######
function status {
    echo "$1运行状况如下："
    systemctl status "$1"
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
