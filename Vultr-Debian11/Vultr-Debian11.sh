#!/bin/bash

#版本号,不得为空
Version=1.67

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

#刷新等待时长
  Standby=50       
#用户选择序号                                     
  option=0   
#更新检查程序网址
  link_update="https://raw.githubusercontent.com/vincilawyer/Bash/main/install-bash.sh"
#nginx配置文件网址
  link_nginx="https://raw.githubusercontent.com/vincilawyer/Bash/main/nginx/default.conf"
#ssh配置文件路径                           
  path_ssh="/etc/ssh/sshd_config"
#nginx配置文件路径                       
  path_nginx="/etc/nginx/conf.d/default.conf" 


                                                                          #更新函数
function update {
    clear && current_Version="$1" bash <(curl -s -L $link_update)
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
      sleep 5
    fi
} 

#执行启动前更新检查
update $Version


function find {
  local start_string="$1"
  local end_string="$2"
  local stop_on_first="${3:-false}"
  local file="$4"
  local found_text=""

  if [[ "$stop_on_first" == "" || "$stop_on_first" == false ]]; then
    found_text=$(awk -v start="$start_string" -v end="$end_string" '{
        if (match($0, start".*"end)) {
          print substr($0, RSTART + length(start), RLENGTH - length(start) - length(end));
        } else if (match($0, start)) {
          print substr($0, RSTART + length(start));
        }
      }' "$file")
  else
    found_text=$(awk -v start="$start_string" -v end="$end_string" '{
        if (match($0, start".*"end)) {
          print substr($0, RSTART + length(start), RLENGTH - length(start) - length(end));
          exit;
        } else if (match($0, start)) {
          print substr($0, RSTART + length(start));
          exit;
        }
      }' "$file")
  fi

  echo "$found_text"
}

function change {
  local start_string="$1"
  local end_string="$2"
  local new_text="$3"
  local file="$4"
  local temp_file="$(mktemp)"

  awk -v start="$start_string" -v end="$end_string" -v new="$new_text" '{
      if (match($0, start".*"end)) {
        print substr($0, 1, RSTART + length(start) - 1) new substr($0, RSTART + RLENGTH - length(end));
      } else {
        print $0;
      }
    }' "$file" > "$temp_file"

  mv "$temp_file" "$file"
}

function delete {
#删除前缀 第几个  在源文件
}

function add {
#添加前缀 第几个  在源文件
}

function insert {
#在文件中某行插入文本，如果文本已存在，则删除前缀
}


                                                                          #修改SSH端口及登录密码的函数
function change_ssh_port {
    #询问SSH端口
    while true; do
      current_ssh_port=$(find "port" " " true $path_ssh)
      echo -e "${GREEN}当前的SSH端口为：$current_ssh_port${NC}"
      read -p "$(echo -e ${BLUE}"请设置新SSH端口（0-65535，空则跳过）：${NC}")" ssh_port
      if [[ -z $ssh_port ]]; then
          echo -e "${RED}已跳过SSH端口设置${NC}"
          break
      elif ! [[ $ssh_port =~ ^[0-9]+$ ]]; then
          echo -e "${RED}端口值输入错误，请重新输入${NC}"
      elif (( $ssh_port < 0 || $ssh_port > 65535 )); then
          echo -e "${RED}端口值输入错误，请重新输入${NC}"
      else 
          # 修改SSH端口
          change "Port " " " "$ssh_port" $path_ssh
          ufw allow $ssh_port/tcp
          echo -e "${GREEN}SSH端口已修改为$ssh_port,并已添加进防火墙规则中。${NC}"
          ufw delete allow $current_ssh_port/tcp
          echo -e "${GREEN}已从防火墙规则中删除原SSH端口号：$current_ssh_port${NC}"
          systemctl restart sshd
          echo -e "${GREEN}当前防火墙运行规则及状态为：${NC}"
          ufw status
          break 
      fi
    done
}

function change_login_password {
    # 询问账户密码
    while true; do
      read -p "$(echo -e ${BLUE}"请设置SSH登录密码（至少8位数字）：${NC}")" ssh_password
      if [[ -z $ssh_password ]]; then
         echo -e "${RED}已跳过登录密码设置${NC}"
         break
      elif (( ${#ssh_password} < 8 )); then
         echo -e "${RED}密码长度应至少为8位，请重新输入${NC}"
      else 
         #修改账户密码
         chpasswd_output=$(echo "root:$ssh_password" | chpasswd 2>&1)
         if echo "$chpasswd_output" | grep -q "BAD PASSWORD" >/dev/null 2>&1; then
            echo -e "${RED}SSH登录密码修改失败,错误原因：${NC}"
            echo "$chpasswd_output" >&2
         else
            echo -e "${GREEN}SSH登录密码已修改成功！${NC}"
         fi
         break
      fi
    done
}





                                                                          # 安装Docker及Compose插件的函数
function install_Docker {

    #安装docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    
    #安装 Compose CLI 插件，可在 https://docs.docker.com/engine/install 文档中更新下载链接
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

    #测试安装。
    docker compose version
}

                                                                         # 安装Nginx_Proxy_Manager的函数
function install_Nginx_PM {
   #创建docker-compose.yml文件
   sudo mkdir -p ~/data/docker_data/nginxproxymanager   
   cd ~/data/docker_data/nginxproxymanager   
   touch docker-compose.yml

   #写入内容
   echo "
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt" >docker-compose.yml
   
   #启动NPM
   docker compose up -d
   
   #提示
   echo "默认登录端口为81
   默认管理员用户：
   Email:    admin@example.com
   Password: changeme"
}


                                                                           # 安装Nginx的函数（设置配置、更新、上传网页等）
function install_Nginx {
    if [ -x "$(command -v nginx)" ]; then
        echo -e "${GREEN}Nginx已经安装，无需重复安装。当前版本号为 $(nginx -v 2>&1)${NC}"
    else
        echo -e "${GREEN}正在更新包列表${NC}"
        apt-get update
        echo -e "${GREEN}包列表更新完成${NC}"
        apt-get install nginx -y
        echo -e "${GREEN}Nginx 安装完成，版本号为 $(nginx -v 2>&1)。${NC}"
        echo -e "${GREEN}正在调整防火墙规则，放开80、443端口 $(nginx -v 2>&1)。${NC}"
        ufw allow http && ufw allow https 
    fi
}

                                                                           # 从github下载更新Nginx配置文件、待测试
function download_nginx_config {
    echo -e "${GREEN}正在载入：${NC}"
    if wget $link_nginx -O $path_nginx; then 
      echo -e "${GREEN}载入完毕${NC}"
    else
      echo -e "${GREEN}下载失败，请检查！${NC}"
    fi
}
                                                                            # 从github下载网页文件
function download_html {
   
    echo "此操作将从github的vincilawyer/Bash/nginx/html目录下载入网页文件，并覆盖原网页文件！(新网页格式需为html)"

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
       path_html=$(find "root" " " "1" $path_nginx)
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

                                                                         
                                                                           # 使用Certbot申请SSL证书的函数
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
      echo -e "${GREEN}正在更新包列表${NC}"
      sudo apt update
      echo -e "${GREEN}包列表更新完成${NC}"
      echo -e "${GREEN}正在安装Certbot...${NC}"
      apt install certbot certbot -y
      echo -e "${GREEN}Certbot安装完成，即将申请SSL证书...${NC}"
    fi
  
    # 申请证书
    certbot certonly --standalone --agree-tos -n -d www.$domain_name -d $domain_name -m $email
    
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

                                                                            # 判断Certbot申请的SSL证书是否存在
function check_ssl_certificate {
    domain_name=$1
    #域名添加www.前缀
    if [[ $domain_name != "www."* ]]; then domain_name="www.${domain_name}"; fi
    #搜索SSL证书
    search_result=$(find /etc/letsencrypt/live/ -name fullchain.pem -print0 | xargs -0 grep -l "$domain_name" 2>/dev/null)
    if [[ -z "$search_result" ]]; then
      return false
    else
      return true
    fi
}

                                                                          # 安装Warp并启动Warp的函数
function install_Warp {
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

                                                                          # 安装X-ui的函数
function install_Xui {
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

                                                                          # 一键搭建服务端的函数
function one_step {
echo "正在安装X-ui面板"
install_Xui
echo "正在安装Nginx"
install_Nginx
echo "正在安装Warp"
install_Warp
echo "请：
1、在x-ui中自行申请SSL
2、上传Nginx配置
3、在x-ui面板中调整xray模板、面板设置，并创建节点"
echo "已暂时关闭防火墙，配置完成后请手动开启"
ufw disable
}


                                                                          # 定义倒计时

function countdown {
    local from=$1
    while [ $from -ge 0 ]; do
        echo -ne "\r${from}s \r"
        if $(read -s -t 1 -n 1); then break; fi
        ((from--))
    done
}
                                                                         # 定义等待函数
function wait {
   echo "请按下任意键返回管理系统"
   read -n 1 -s input
}

                                                                         # 定义选择功能错误函数
function error_option {
       echo -e "${RED}输入不正确，请重新输入${NC}"
       countdown 3
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
  read option
  
#  while ! read -t $Standby input; do
#     #发送空内容
#     echo -n "."
#     echo -ne "\b"
#  done

  clear
  if [ "$option" == "0" ]; then
      echo $option
      exit 0
  fi
  echo
}

# 定义菜单选项
    main_menu=(
    "  1、修改SSH登录端口和登录密码"
    "  2、UFW防火墙管理"
    "  3、强制更新脚本"
    "——————————————————————————————————"
    "  4、一键搭建科学上网服务端"
    "  5、Docker及Compose管理"
    "  6、Nginx服务"
    "  7、Warp服务"
    "  8、X-ui服务"
    "——————————————————————————————————"
    "  0、退出"
    )
    NFW_menu=(
    "  1、返回上一级"
    "  2、启动防火墙"
    "  3、关闭防火墙"
    "  4、查看防火墙规则"
    "  0、退出"   
    )
    
    Docker_menu=(
    "  1、返回上一级"
    "  2、安装Docker及Compose插件"
    "  3、卸载Docker及Compose插件"
    "  0、退出"   
    )
    
    Nginx_menu=(
    "  1、返回上一级"
    "  2、安装Nginx Proxy Manager"
    "  3、安装Nginx"
    "  3、申请SSL证书"
    "  5、修改Nginx配置"
    "  6、从github下载更新配置文件"
    "  7、查看Nginx配置文件"
    "  8、查看网页文件根目录"
    "  9、停止运行Nginx"
    "  10、卸载"
    "  0、退出"   
    )
    Xui_menu=(
    "  1、返回上一级"
    "  2、安装\更新Xui面板"
    "  3、进入Xui面板管理（指令:x-ui）"
    "  0、退出" 
    )
    Warp_menu=(
    "  1、返回上一级"
    "  2、安装Warp"
    "  3、停止运行"
    "  4、卸载"
    "  0、退出"
    )
     other_menu=(
    "  1、返回上一级"
    "  2、关闭防火墙"
    "  0、退出"
    )


                                                                           # 主函数
function main {
  #判断系统是否适配
  if [ ! $(lsb_release -rs) = "11" ]; then 
  echo "请注意，本脚本是适用于Vulre服务器Debian11系统，用于其他系统或版本时将可能出错！"
  wait;
  fi
  
  #显示页面及选项
  while true; do
    Option "请选择以下操作选项" "${main_menu[@]}"
    case $option in
    
    #一级菜单134选项
        1 | 3 | 4)
            case $option in
                1) change_ssh_port
                   change_login_password;;
                3) update "force";;
                4) one_step 
            esac
            wait;;
            
     #一级菜单25678选项
       2 | 5 | 6 | 7 | 8)
       
            get_option=$option
            
            while true; do
               case $get_option in
               
                 #一级菜单2 防火墙选项
                 2) Option ${main_menu[$(($get_option - 1))]} "${NFW_menu[@]}"
                    case $option in
                           2 | 3 | 4)
                               case $option in
                                   2)sudo ufw enable;;
                                   3)sudo ufw disable;;
                                   4)sudo ufw status verbose;; 
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                    esac;;
                 
                 #一级菜单5 Docker选项
                 5) Option ${main_menu[$(($get_option - 1))]} "${Docker_menu[@]}"
                    case $option in
                           2 | 3)
                               case $option in
                                   2)install_Docker;;
                                   3)echo "没开发呢！";;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                    esac;;
                  
    
                  #一级菜单6 Nginx选项
                 6) Option ${main_menu[$(($get_option - 1))]} "${Nginx_menu[@]}"
                    case $option in
                           2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10)
                               case $option in
                                   2)install_Nginx_PM;;
                                   3)install_Nginx;;
                                   4)apply_ssl_certificate;;
                                   5)set_nginx_config;;
                                   6)download_nginx_config;;
                                   7)nano /etc/nginx/conf.d/default.conf;;
                                   9)stop "nginx";;
                                   10)echo "没开发呢！";;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                    esac;;
                                            
                  #一级菜单7 Warp选项
                  7) Option ${main_menu[$(($get_option - 1))]} "${Warp_menu[@]}" 
                        case $option in
                           2 | 3 | 4)
                               case $option in
                                   2)install_Warp;;
                                   3);;
                                   4)echo "没开发呢！";;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                        esac;;
                        
                  #一级菜单8 Xui选项
                  8)Option ${main_menu[$(($get_option - 1))]} "${Xui_menu[@]}" 
                        case $option in
                            2 | 3 | 4 | 5 | 6 | 7)
                               case $option in
                                   2)install_Xui;;
                                   3)x-ui;;
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
