#####防火墙管理#####
ufw_menu=(
    "返回上一级"            "return"
    "启用防火墙规则"         "ufw enable"
    "停用防火墙规则"         "ufw disable"
    "查看防火墙规则"         "ufw status verbose"
    "防火墙程序管理"         'get_appmanage_menu "ufw"; page true "UFW" "${appmanage_menu[@]}"'
    )     
   
    
###### 查看ip信息 ######
function ipinfo {
  echo "本机IP信息："
  hostname -I
  
#代理端口列表
apps=(
"Warp"
"Tor"
)
   echo "网络状况"
   echo "代理IP信息："
   for app in "${apps[@]}"; do  
       port_value=$(eval echo \$"${app}_port")
       echo "$app(端口$port_value)的代理IP地址为："
       curl --socks5-hostname localhost:"$port_value" http://api.ipify.org
      echo
   done
}

#######  修改SSH端口    #######  
path_ssh="/etc/ssh/sshd_config" 
function change_ssh_port {
    if settext "Port " " " "" 1 false false true true $path_ssh "SSH端口" "0-65535" 1 $port_regex; then
          echo -e "${GREEN}已正从防火墙规则中删除原SSH端口号：$old_text${NC}"
          ufw delete allow $old_text/tcp   
          echo -e "${GREEN}正在将新端口"$new_text"添加进防火墙规则中。${NC}"
          ufw allow "$new_text"/tcp  
          systemctl restart sshd
          echo -e "${GREEN}当前防火墙运行规则及状态为：${NC}"
          ufw status
    fi  
}

#######  修改登录密码    ####### 
function change_login_password {
    # 询问账户密码 
    if settext "@" "@" "" "" "" "" "" false "@********@" "SSH登录密码" "至少8位" 1 ".{8,}"; then 
         #修改账户密码
         chpasswd_output=$(echo "root:$new_text" | chpasswd 2>&1)
         if echo "$chpasswd_output" | grep -q "BAD PASSWORD" >/dev/null 2>&1; then
            echo -e "${RED}SSH登录密码修改失败,错误原因：${NC}"
            echo "$chpasswd_output" >&2
         else
            echo -e "${GREEN}SSH登录密码已修改成功！新密码为:$new_text,请妥善保管！${NC}"
         fi
   fi
}

### 查看所有程序运行状况 ####
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

