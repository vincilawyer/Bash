############################################################################################################################################################################################
############################################################################## 程序管理源代码   ########################################################################################
############################################################################################################################################################################################
###菜单栏
Program_menu=(
    "更新软件包列表及软件"                      "aptup"
    "查看所有重要程序systemd服务状态"           "status_all"
    "监测系统动态资源(top)"                "top; continue"
    "程序树(pstree -Aup)"             "pstree -Aup" 
    )    

#######  更新软件包列表及软件   ########
function aptup {
echo "开始更新软件包列表..."
apt update
echo "软件包列表更新完成，开始更新本机软件包..."
apt upgrade
echo "更新结束"
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

### 查看重要程序服务状况 ####
function status_all {
apps=(
"ufw"
"docker"
"nginx"
"warp-svc"
"tor"
"frps"
"alist"
)
   for app in "${apps[@]}"; do  
      zl="systemctl status $app"
      i=1
      while IFS= read -r line; do
          if (( "$i" == 1 )); then
              echo -e "${RED}${line}${NC}"
          else
              echo "$line"
          fi
          i=$((i+1))
      done < <($zl)
   done
}



