#!/bin/bash
#版本号,不得为空
Version=1.41

#定义彩色字体
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BLACK="\033[40m"
NC='\033[0m'

#其他参数
Standby=50  #刷新等待时长
option=0    #选项
                                                                        #倒计时

function countdown {
    local from=$1
    while [ $from -ge 0 ]; do
        echo -ne "\r${from}s \r"
        if $(read -s -t 1 -n 1); then
        break
        fi
        ((from--))
    done
}



                                                                          #更新函数
function update {
    clear && current_Version="$1" bash <(curl -s -L https://raw.githubusercontent.com/vincilawyer/Bash/main/install-bash.sh)
    no=$?
    #如果成功更新
    if [ $no == 1 ]; then
      exit 
    #如果无需更新  
    elif [ $no == 0 ]; then
    :
    #如果更新失败
    else
      echo "更新检查错误，请检查网络！"
      countdown 5
    fi
} 

#执行启动前更新检查
update $Version


                                                                          #修改SSH端口的函数
function change_ssh_port {
    #询问SSH端口
  while true; do
    current_ssh_port=$(grep -i "port" /etc/ssh/sshd_config | awk '{print $2}' | head -1)
    echo -e "${GREEN}当前的SSH端口为：$current_ssh_port${NC}"
    read -p "$(echo -e ${BLUE}"请设置新SSH端口（0-65535，空则跳过）：${NC}")" ssh_port
    if [[ -z $ssh_port ]]; then
        echo -e "${RED}已取消SSH端口设置${NC}"
        break
    elif ! [[ $ssh_port =~ ^[0-9]+$ ]]; then
        echo -e "${RED}端口值输入错误，请重新输入${NC}"
    elif (( $ssh_port < 0 || $ssh_port > 65535 )); then
        echo -e "${RED}端口值输入错误，请重新输入${NC}"
    else
        break
    fi
  done

    # 修改SSH端口
  if [[ -n $ssh_port ]]; then
    sed -E -i "s/^(#\s*)?Port\s+.*/Port $ssh_port/" /etc/ssh/sshd_config
    ufw allow $ssh_port/tcp
    echo -e "${GREEN}SSH端口已修改为$ssh_port,并已添加进防火墙规则中。${NC}"
    ufw delete allow $current_ssh_port/tcp
    echo -e "${GREEN}已从防火墙规则中删除原SSH端口号：$current_ssh_port${NC}"
    systemctl restart sshd
    echo -e "${GREEN}当前防火墙运行规则及状态为：${NC}"
    ufw status 
  fi
}
                                                                           # 修改登录密码的函数
function change_login_password {
    # 询问账户密码
  while true; do
    read -p "$(echo -e ${BLUE}"请设置SSH登录密码（至少8位数字）：${NC}")" ssh_password
    if [[ -z $ssh_password ]]; then
    echo -e "${RED}已取消登录密码设置${NC}"
        break
    elif (( ${#ssh_password} < 8 )); then
        echo -e "${RED}密码长度应至少为8位，请重新输入${NC}"
    else
        break
    fi
  done

    # 修改账户密码
  if [[ -n $ssh_password ]]; then
    chpasswd_output=$(echo "root:$ssh_password" | chpasswd 2>&1)
     if echo "$chpasswd_output" | grep -q "BAD PASSWORD" >/dev/null 2>&1; then
       echo -e "${RED}SSH登录密码修改失败,错误原因：${NC}"
       echo "$chpasswd_output" >&2
     else
       echo -e "${GREEN}SSH登录密码已修改成功！${NC}"
     fi
  fi
}
                                                                           # 判断SSL证书是否存在
function check_ssl_certificate {
    domain_name=$1

    if [[ $domain_name != "www."* ]]; then
         domain_name="www.${domain_name}"
    fi
     
    search_result=$(find /etc/letsencrypt/live/ -name fullchain.pem -print0 | xargs -0 grep -l "$domain_name" 2>/dev/null)
    if [[ -z "$search_result" ]]; then
      return 0
    else
      return 1
    fi
}
                                                                           # 申请SSL证书的函数（待测试）
function apply_ssl_certificate {
  # 输入域名
    while true; do
        read -p "$(echo -e ${BLUE}"请输入申请SSL证书域名（不加www.）: ${NC}")" domain_name
        if [[ -z $domain_name ]]; then
          echo -e "${RED}未输入域名，退出申请操作${NC}"
          return
        elif [[ $domain_name =~ ^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$ ]]; then
            domain_name=${domain_name#www.}
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
   # 更新包列表
    echo -e "${GREEN}正在更新包列表${NC}"
    sudo apt update
    echo -e "${GREEN}包列表更新完成${NC}"
    echo -e "${GREEN}正在安装Certbot...${NC}"
    apt install certbot python3-certbot-nginx -y
    echo -e "${GREEN}Certbot安装完成，即将申请SSL证书...${NC}"
  fi
  
  # 申请证书
    certbot certonly --standalone --agree-tos -n -d www.$domain_name -d $domain_name -m $email
    
  # 判断申请结果
    if [[ $(check_ssl_certificate "$domain_name") -eq 1 ]]; then
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
    
 
    
  # 重启nginx和防火墙
  if [ -x "$(command -v nginx)" ]; then
     echo -e "${GREEN}正常恢复nginx运行${NC}"  
     systemctl start nginx
  fi  
  echo -e "${GREEN}正在恢复防火墙运行${NC}"  
  ufw --force enable

}


                                                                           # 安装V2Ray的函数（配置上传、设置配置、更新等）
function install_v2ray {
    if [ -x "$(command -v v2ray)" ]; then
        echo -e "${GREEN}V2Ray已安装，无需重复安装${NC}"
    else
        bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
        if bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) 2>&1 | tee /tmp/install_log | grep -q "is installed"; then
            echo "V2Ray安装成功！"
        else
            echo "V2Ray 安装失败！以下是安装过程的全部信息："
            cat /tmp/install_log
        fi
    fi
}

                                                                           # 安装Nginx的函数（设置配置、更新、上传网页等）
function install_nginx {
    if [ -x "$(command -v nginx)" ]; then
        echo -e "${GREEN}Nginx已经安装，版本号为 $(nginx -v 2>&1)，无需重复安装${NC}"
    else
        echo -e "${GREEN}正在更新包列表${NC}"
        apt-get update
        echo -e "${GREEN}包列表更新完成${NC}"
        apt-get install nginx -y
        echo -e "${GREEN}Nginx 安装完成，版本号为 $(nginx -v 2>&1)。${NC}"
        echo -e "${GREEN}正在启动防火墙，并放开80、443端口 $(nginx -v 2>&1)。${NC}"
        ufw enable && ufw allow http && ufw allow https 
        echo -e "${GREEN}从github下载Nginx配置文件${NC}"
        download_nginx_config
    fi
}

                                                                           # 从github下载更新Nginx配置文件、待测试
function download_nginx_config {
    echo -e "${GREEN}正在载入：${NC}"
    wget https://raw.githubusercontent.com/vincilawyer/Bash/main/nginx/default.conf -O /etc/nginx/conf.d/default.conf
    echo -e "${GREEN}载入完毕${NC}"
}

                                                                           # 设置Nginx配置、待测试
function set_nginx_config {
     # 输入域名
    while true; do
        read -p "$(echo -e ${YELLOW}"请输入网站域名（不加www.）: ${NC}")" domain_name
        if [[ -z $domain_name ]]; then
          echo -e "${GREEN}取消域名设置${NC}"
          break
          # 域名输入正确
        elif [[ $domain_name =~ ^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$ ]]; then
            if [[ $domain_name != "www."* ]]; then
                domain_name="www.${domain_name}"
                if check_ssl_certificate "$domain_name"=0; then
                     echo -e "${RED}请注意，该域名的SSL证书尚不存在，请及时申请！${NC}"
                fi
                sed -i "s/server_name[[:space:]]\+www\.[[:alnum:]\.\-]*;/server_name $DOMAIN;    ### 填写域名，注意这里的域名带www/" /etc/nginx/conf.d/default.conf
                echo -e "${GREEN}网站域名设置成功${NC}"
            fi
            break
        else
            echo -e "${RED}输入格式不正确，请重新输入${NC}"
        fi
    done

    # 提示输入文件路径
    while true; do
        read -p "请输入网页文件路径（默认为/var/www/html）：" path
        if [[ -z "$path" ]]; then
            echo -e "${GREEN}取消路径设置${NC}"
            break
        elif [[ ! -e "$path" ]]; then
            echo "文件夹不存在，请重新输入"
        else
            break
        fi
    done
    
    echo "以下是为V2ray提供伪装的配置参数"
    
    #输入v2ray监听端口
     while true; do
    read -p "$(echo -e ${YELLOW}"请填写v2ray监听端口（0-65535，空则跳过）：${NC}")" ssh_port
    if [[ -z $ssh_port ]]; then
        echo -e "${RED}取消v2ray监听端口设置${NC}"
        break
    elif ! [[ $ssh_port =~ ^[0-9]+$ ]]; then
        echo -e "${RED}端口值输入错误，请重新输入${NC}"
    elif (( $ssh_port < 0 || $ssh_port > 65535 )); then
        echo -e "${RED}端口值输入错误，请重新输入${NC}"
    else
        break
    fi
    done
    
    #输入path密钥
    read -p "$(echo -e ${YELLOW}"请填写v2rayPath密钥：${NC}")" Path
    if [[ -z "$Path" ]]; then
        echo -e "${RED}取消v2rayPath密钥设置${NC}"
    fi   
}

                                                                          # 安装Warp并启动Warp的函数（需补充关闭warp、更换ip）
function install_warp {
    if [ -e "/usr/bin/cloudflared" ]; then
        echo -e "${GREEN}Warp已安装，无需重复安装，当前代理IP地址为：${NC}"
        curl ifconfig.me --proxy socks5://127.0.0.1:40000        
    else
        #先安装WARP仓库GPG密钥：
        echo -e "${GREEN}正在安装WARP仓库GPG 密钥${NC}"
        curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
        #添加WARP源：
        echo -e "${GREEN}正在添加WARP源${NC}"
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
        #更新源
        echo -e "${GREEN}正在更新包列表${NC}"
        sudo apt update
        #安装Warp
        echo -e "${GREEN}开始安装Warp${NC}"
        apt install cloudflare-warp -y
        #注册WARP：
        echo -e "${GREEN}注册WARP中，请输入y予以确认${NC}"
        warp-cli register
        #设置为代理模式（一定要先设置）：
        echo -e "${GREEN}设置代理模式${NC}"
        warp-cli set-mode proxy
        #连接WARP：
        echo -e "${GREEN}连接WARP${NC}"
        warp-cli connect
        sleep 2
        #查询代理后的IP地址：
        echo -e "${GREEN}Warp 安装完成，代理IP地址为：${NC}"
        curl ifconfig.me --proxy socks5://127.0.0.1:40000
        echo
    fi
}

                                                                            #开启BBR加速的函数
function enable_bbr() {
    if grep -q "net.core.default_qdisc = fq" /etc/sysctl.conf && grep -q "net.ipv4.tcp_congestion_control = bbr" /etc/sysctl.conf; then    
      if sysctl net.ipv4.tcp_congestion_control | grep -q "bbr"; then
        echo "已开启BBR加速，无需再次开启"
      else
        echo "未开启，请重试..."
        sysctl -p
      fi
    else
      echo "正在开启..."
      bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
      bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
      sysctl -p
      if sysctl net.ipv4.tcp_congestion_control | grep -q "bbr"; then
         echo "已成功开启BBR加速！"
      else
         echo "未成功开启，请重试..."
      fi
    fi
}

                                                                          #查看 v2ray、nginx、warp、ufw运行状态
function check_processes() {
  systemctl status -l v2ray nginx warp-svc ufw
}

                                                                           #重启v2ray、nginx、warp、ufw
function restart_processes() {
  systemctl restart v2ray nginx warp-svc ufw
  if [ $? -eq 0 ]; then
   echo "已重启完成"
  else
   echo "发生错误，请检查以上错误内容。"
  fi
}
                                                                              #停止运行程序
function stop {
   systemctl stop $1
   if [ $? -eq 0 ]; then
         echo "已停止运行$1"
   else
        echo "发生错误，请检查以上错误内容。"
   fi
}   

                                                                           # 定义选择功能序号函数
function error_option {
       echo -e "${RED}输入不正确，请重新输入${NC}"
       countdown 3
}

                                                                          # 定义等待函数
function wait {
   echo "请按下任意键返回管理系统"
   read -n 1 -s input
}
                                                                          # 页面显示函数
function Page {
clear
art=$(cat << "EOF"
  __     __                         _   _           ____                   
  \ \   /"/u          ___          | \ |"|       U /"___|         ___      
    \ \ / //          |_"_|        <|  \| |>      \| | u          |_"_|     
    /\ V /_,-.         | |         U| |\  |u       | |/__          | |      
   U  \_/-(_/        U/| |\u        |_| \_|         \____|       U/| |\u    
     //           .-,_|___|_,-.     ||   \\,-.     _// \\     .-,_|___|_,-. 
    (__)           \_)-' '-(_/      (_")  (_/     (__)(__)     \_)-' '-(_/ 
EOF
)

  echo
  echo -e "${RED}${art}${NC}"
  echo
  echo
  echo "                   欢迎进入Vinci服务器管理系统(版本V$Version)"
  echo
  echo "=========================== "$1" =============================="
  echo 
}
                                                                          # 选择内容函数
function Option {
  Page $1
  #展示选项
  for menu in "${@:2}"
  do
    echo "$menu"
  done
  echo
  echo -n "  请按序号选择操作: "
  #监听输入
  while ! read -t $Standby input; do
     #发送空内容
     echo -n "."
     echo -ne "\b"
  done
  option=$input 
  clear
  if [[ $option -eq 0 ]]; then
      exit 0
  fi
  echo
}

# 定义菜单选项
    main_menu=(
    "  1、修改SSH登录端口和登录密码"
    "  2、Nginx服务"
    "  3、V2ray服务"
    "  4、Warp服务"
    "  5、重启Nginx、V2ray、Warp、UFW"
    "  6、查看NVWU运行状态"
    "  7、强制更新脚本"
    "  0、退出"
    )
    
    Nginx_menu=(
    "  1、返回上一级"
    "  2、安装Nginx"
    "  3、从github下载更新配置文件"
    "  4、从github下载更新网页文件"
    "  5、修改Nginx配置"
    "  6、查看Nginx配置文件"
    "  7、申请SSL证书"
    "  8、停止运行Nginx"
    "  9、卸载"
    "  0、退出"   
    )
    V2ray_menu=(
    "  1、返回上一级"
    "  2、安装V2ray"
    "  3、从github下载更新配置文件"
    "  4、修改V2ray配置"
    "  5、查看V2ray配置文件"
    "  6、停止运行V2ray"
    "  7、卸载"
    "  0、退出" 
    )
    Warp_menu=(
    "  1、返回上一级"
    "  2、安装Warp"
    "  3、停止运行"
    "  4、卸载"
    "  0、退出"
    )


                                                                           # 主函数
function main {
  while true; do
    Option "请选择以下操作选项" "${main_menu[@]}"
    case $option in
    #一级菜单1567选项
        1 | 5 | 6 | 7)
            case $option in
                1) change_ssh_port
                   change_login_password;;
                5) restart_processes;;
                6) check_processes;;
                7) update "force";;
            esac
            wait;;
     #一级菜单234选项
       2 | 3 | 4)
            while true; do
               case $option in
               
                 #一级菜单2选项
                 2) Option ${main_menu[$(($option - 1))]} "${Nginx_menu[@]}"
                    case $option in
                           2 | 3 | 4 | 5 | 6 | 7 | 8)
                               case $option in
                                   2)install_nginx;;
                                   3)download_nginx_config;;
                                   4);;
                                   5)set_nginx_config;;
                                   6)nano /etc/nginx/conf.d/default.conf;;
                                   7)apply_ssl_certificate;;
                                   8)stop "nginx";;
                                   9)echo "没开发呢！";;
                              esac
                              wait;;
                          1)break;;
                          *)error_option;;
                    esac;;
                        
                  #一级菜单3选项
                  3)Option ${main_menu[$(($option - 1))]} "${V2ray_menu[@]}" 
                        case $option in
                            2 | 3 | 4 | 5 | 6 | 7 | 8)
                               case $option in
                                   2)install_v2ray;;
                                   3);;
                                   4);;
                                   5)nano /usr/local/etc/v2ray/config.json;;
                                   6)stop "v2ray";;
                                   7)echo "没开发呢！";;
                              esac
                              wait;;
                          1)break;;
                          *)error_option;;
                        esac;; 
                        
                  #一级菜单4选项
                  4) Option ${main_menu[$(($option - 1))]} "${V2ray_menu[@]}" 
                        case $option in
                           2 | 3 | 4 | 5 | 6 | 7 | 8)
                               case $option in
                                   2)install_warp;;
                                   3);;
                                   4)echo "没开发呢！";;
                              esac
                              wait;;
                          1)break;;
                          *)error_option;;
                        esac;;
              esac
           done;;    
       #一级菜单其他选项  
       *) error_option;;
     esac
  done
    
}

                                                                           # 调用主函数
main

