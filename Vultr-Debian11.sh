#!/bin/bash

#定义彩色字体
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'


#修改SSH端口的函数
function change_ssh_port {
    #询问SSH端口
  while true; do
    read -p "$(echo -e ${YELLOW}"请设置SSH端口（0-65535，空则跳过）：${NC}")" ssh_port
    if [[ -z $ssh_port ]]; then
        break
    elif ! [[ $ssh_port =~ ^[0-9]+$ ]]; then
        echo -e "${RED}输入内容不正常，请重新输入${NC}"
    elif (( $ssh_port < 0 || $ssh_port > 65535 )); then
        echo -e "${RED}输入内容不正常，请重新输入${NC}"
    else
        break
    fi
  done

    # 修改SSH端口
  if [[ -n $ssh_port ]]; then
    sed -i "s/#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
    systemctl restart sshd
    echo -e "${GREEN}SSH端口已修改为$ssh_port，请务必修改防火墙规则！${NC}"
  fi
}

# 修改登录密码的函数
function change_login_password {
    # 询问账户密码
  while true; do
    read -p "$(echo -e ${YELLOW}"请设置SSH登录密码（至少8位数字）：${NC}")" ssh_password
    if [[ -z $ssh_password ]]; then
        break
    elif (( ${#ssh_password} < 8 )); then
        echo -e "${RED}密码长度应至少为8位，请重新输入${NC}"
    else
        break
    fi
  done

    # 修改账户密码
  if [[ -n $ssh_password ]]; then
    echo "root:$ssh_password" | chpasswd
    echo -e "${GREEN}SSH登录密码已修改${NC}"
  fi
}


# 申请SSL证书的函数
function apply_ssl_certificate {

  # 更新包列表
  sudo apt update

  # 检查并安装Certbot
  if [ -x "$(command -v certbot)" ]; then
    echo -e "${GREEN}本机已安装Certbot，无需重复安装${NC}"
  else
    echo -e "${YELLOW}正在安装Certbot...${NC}"
    apt install certbot python3-certbot-nginx
    echo -e "${YELLOW}Certbot安装完成${NC}"
  fi

  # 停止nginx运行
  sudo systemctl stop nginx
  echo "${GREEN}已停止nginx运行${NC}"

  #关闭防火墙
  ufw disable 
  echo "${GREEN}已关闭防火墙${NC}"

  # 输入域名
    while true; do
        read -p "请输入申请SSL证书域名（不加www.）: " domain_name
        if [[ -z $domain_name ]]; then
          echo -e "${GREEN}未输入域名，退出申请操作${NC}"
          return
        elif [[ $domain_name =~ ^[0-9]+(\.[0-9]+){3}$ || ! $domain_name =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]{1,61}[a-zA-Z0-9]$ ]]; then
            echo -e "${RED}输入格式不正确，请重新输入${NC}"
        else
            domain_name=${domain_name#www.}
            break
        fi
    done
  # 输入邮箱
    while true; do
        read -p "请输入申请SSL证书邮箱: " email
        if [[ -z $email || ! $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo -e "${RED}输入格式不正确，请重新输入${NC}"
        else
            break
        fi
    done
  # 申请证书
    sudo certbot certonly --standalone --agree-tos -n -d www.$domain_name -d $domain_name -m $email
    echo -e "${GREEN}SSL证书申请已完成，证书文件为：${NC}"
    find /etc/letsencrypt/live/ -name fullchain.pem
  # 证书自动续约
    echo "0 0 1 */2 * service nginx stop; certbot renew; service nginx start;" | crontab
    if [ $? -eq 0 ]; then
    else
        echo "${GREEN}已启动证书自动续约${NC}"
    fi
}

# 安装V2Ray的函数
function install_v2ray {
    if [ -e "/usr/local/bin/v2ray" ]; then
        echo -e "${GREEN}V2Ray已安装，无需重复安装${NC}"
    else
        bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
        echo -e "${GREEN}V2Ray安装完成${NC}"
    fi
}

# 安装Nginx的函数
function install_nginx {
    if [ -e "/etc/nginx" ]; then
        echo -e "${GREEN}Nginx 已安装，无需重复安装${NC}"
    else
        apt-get update
        apt-get install nginx -y
        echo -e "${GREEN}Nginx 安装完成${NC}"
    fi
}

# 安装Warp的函数
function install_warp {
    if [ -e "/usr/bin/cloudflared" ]; then
        echo -e "${GREEN}Warp 已安装，无需重复安装${NC}"
    else
        #先安装WARP仓库GPG 密钥：
        curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        #添加WARP源：
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        #更新源
        sudo apt update
        #安装Warp
        apt install cloudflare-warp
        #注册WARP：
        warp-cli register
        #设置为代理模式（一定要先设置）：
        warp-cli set-mode proxy
        #连接WARP：
        warp-cli connect
        #查询代理后的IP地址：
        echo -e "${GREEN}Warp 安装完成，代理IP地址为：${NC}"
        curl ifconfig.me --proxy socks5://127.0.0.1:40000
    fi
}







