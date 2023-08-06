#############################################################################################################################################################################################
##############################################################################   10.Nginx模块  ################################################################################################
############################################################################################################################################################################################

### 菜单栏  ####
nginx_menu=(
    "安装Nginx"              "install_Nginx"
    "设置Nginx配置"           'echo "维护中"'
    "查看Nginx日志"            "nano /var/log/nginx/access.log; continue"
    "程序管理"                 'get_appmanage_menu "nginx"; page "Nginx" "${appmanage_menu[@]}"'
    )
    
### 路径 ###
#nginx配置文件网址
link_nginx_config="https://raw.githubusercontent.com/vincilawyer/Bash/main/nginx/default.conf"
#nginx配置文件路径 (查看配置：nano /etc/nginx/conf.d/default.conf)                      
path_nginx_config="/etc/nginx/conf.d/default.conf" 
#nginx日志文件路径
log_nginx="/var/log/nginx/access.log"
#nginx 80端口默认服务块文件路径
default_nginx="/etc/nginx/sites-enabled/default"



####### 安装Nginx ######
function install_Nginx {
        installed "nginx" && return    #检验安装
        echo -e "${GREEN}正在更新包列表${NC}"
        apt-get update
        echo -e "${GREEN}包列表更新完成${NC}"
        apt-get install nginx -y
        echo -e "${GREEN}Nginx 安装完成，版本号为 $(nginx -v 2>&1)。${NC}"
        echo -e "${GREEN}正在调整防火墙规则，放开80、443端口。${NC}"
        ufw allow http && ufw allow https 
        echo -e "${GREEN}正在调整Nginx配置${NC}"
        download_nginx_config
        echo "" > $default_nginx   # 清空nginx对80端口默认服务块的配置内容

}

####### 从github下载更新Nginx配置文件 ####### 
function download_nginx_config {
      if confirm "是否从Github下载更新Nginx配置文件？此举动将覆盖原配置文件" "已取消下载更新Nginx配置文件"; then return; fi
      echo -e "${GREEN}正在载入：${NC}"
      if wget $link_nginx_config -O $path_nginx_config; then 
         echo -e "${GREEN}载入完毕，第一次使用请设置配置：${NC}"
        set_nginx_config
    else
            echo -e "${GREEN}下载失败，请检查！${NC}"
         fi       
}

####### 设置Nginx配置 ####### 
function set_nginx_config {
     echo "维护中，请手动导入配置！"
     return
       if ! [ -x "$(command -v nginx)" ]; then
          echo -e "${RED}Nginx尚未安装，请先进行安装！${NC}"
       fi
       current_domain=$(search "server_name " ";" 1 $path_nginx_config true false)
       set "ssl_certificate " "/$current_domain" 1 $path_nginx_config true "SSL证书存放路径"
       current_ssl_path=$(search "ssl_certificate " "$current_domain" 1 $path_nginx_config true false)
       if set "server_name " ";" 1 $path_nginx_config true "VPS域名" "" true "^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$"; then
           replace  "$current_ssl_path" ".cer;" 1 "$text2" $path_nginx_config true
           replace  "$current_ssl_path" ".key;" 1 "$text2" $path_nginx_config true
       fi
       if set "https://" "; #伪装网址" 1 $path_nginx_config true "伪装域名" "" true "^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$"; then
           replace  "sub_filter \"" "\"" 1 "$text2" $path_nginx_config true
           replace  "proxy_set_header Host \"" "\"" 1 "$text2" $path_nginx_config true
       fi
       set "location /ray-" " {" 1 $path_nginx_config true "xray分流路径" "省略/ray-前缀，"
       set "http://127.0.0.1:" "; #Xray端口" 1 $path_nginx_config true "Xray监听端口" "0-65535，" true "^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
       set "location /xui-" " {" 1 $path_nginx_config true "x-ui面板分流路径" "省略/xui-前缀，"
       set "http://127.0.0.1:" "; #xui端口" 1 $path_nginx_config true "X-ui监听端口" "0-65535，" true "^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
       echo "正在重启Nginx..."
       if nginx -t &> /dev/null; then
          systemctl restart nginx
          return
       fi
       echo "Nginx配置文件存在错误，请检查并修改后重启！"
}   
####### 从github下载网页文件 ####### 
function download_html {
   echo "维护中..."
   return
   if confirm "此操作将从Github的vincilawyer/Bash/nginx/html目录下载入网页文件，并覆盖原网页文件！" "已取消下载更新网页文件"; then return; fi
    #输入主题名称
    read -p "请输入网页主题名称（例如Moon）：" input
    if [[ -z $input ]]; then 
        echo "已取消操作!"
        return
    fi
    echo "正在下载网页zip压缩包..."

    #开始下载并覆盖
    if wget "$link_html$input".zip -O /home/"$input".zip; then
       echo "压缩包下载完成，开始解压"
       unzip /home/"$input".zip -d /home
       path_html=$(search "root" " ")
       echo "开始覆盖原网页文件"
       rm -r "$path_html"/*  >/dev/null
       mv /home/"$input"/* "$path_html"/
       echo "已更新网页文件！"
       rm -r /home/"$input".zip
       rm -r /home/"$input"
       rm -rf /home/__MACOSX >/dev/null
       echo "已清除压缩包！"
   else
       echo "下载失败，请检查文件名称或网络！"
   fi    
}

                                                                         
#######  使用Certbot申请SSL证书的函数 ####### 
function apply_ssl_certificate {
   echo "维护中"
   return
    # 输入域名
    while true; do
        read -p "$(echo -e ${BLUE}"请输入申请SSL证书域名（不加www.）: ${NC}")" domain_name
        if [[ -z $domain_name ]]; then
          echo -e "${RED}未输入域名，退出申请操作${NC}"
          return
        elif [[ $domain_name =~ ^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo -e "${RED}输入格式不正确，请重新输入${NC}"
        fi
    done

    # 输入邮箱
    while true; do
        read -p "$(echo -e ${BLUE}"请输入申请SSL证书邮箱: ${NC}")" email
        if [[ -z $email || ! $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo -e "${RED}输入格式不正确，请重新输入${NC}"
        else
            break
        fi
    done
    
  
    # 停止nginx运行
    if [ -x "$(command -v nginx)" ]; then
       systemctl stop nginx
       echo -e "${GREEN}为了防止80端口被占用，已停止nginx运行${NC}"
    fi  
  
    #关闭防火墙
    ufw disable 
    echo -e "${GREEN}为了防止证书申请失败，已关闭防火墙${NC}"

    # 检查并安装Certbot
    if [ -x "$(command -v certbot)" ]; then
      echo -e "${GREEN}本机已安装Certbot，无需重复安装，即将申请SSL证书...${NC}"
    else
      echo -e "${GREEN}正在更新包列表${NC}"
      sudo apt update
      echo -e "${GREEN}包列表更新完成${NC}"
      echo -e "${GREEN}正在安装Certbot...${NC}"
      apt install certbot certbot -y
      echo -e "${GREEN}Certbot安装完成，即将申请SSL证书...${NC}"
    fi
  
    # 申请证书
    certbot certonly --standalone --agree-tos -n -d $domain_name -m $email
    
    # 判断申请结果
    if check_ssl_certificate "$domain_name"; then
        echo -e "${GREEN}SSL证书申请已完成！${NC}"
        # 证书自动续约
        echo "0 0 1 */2 * service nginx stop; certbot renew; service nginx start;" | crontab
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}未成功启动证书自动续约${NC}"
        else
            echo -e "${GREEN}已启动证书自动续约${NC}"
        fi
    else
        echo -e "${RED}SSL证书申请失败！${NC}"
    fi
    
    # 重启nginx
    if [ -x "$(command -v nginx)" ]; then
       echo -e "${GREEN}正常恢复nginx运行${NC}"  
       systemctl start nginx
    fi  

    #重启防火墙
    echo -e "${GREEN}正在恢复防火墙运行${NC}"  
    ufw --force enable
}

#######  判断Certbot申请的SSL证书是否存在  ####### 
function check_ssl_certificate {
   echo "维护中"
   return
    domain_name="$1"
    ssl_path="$2"
    #搜索SSL证书
    search_result=$(find "$2/" -name fullchain.pem -print0 | xargs -0 grep -l "$domain_name" 2>/dev/null)
    if [[ -z "$search_result" ]]; then
      return false
    else
      return true
    fi
}
