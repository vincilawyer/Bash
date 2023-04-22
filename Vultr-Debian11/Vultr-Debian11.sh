#!/bin/bash

#版本号,不得为空
Version=1.54

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


                                                                          # 安装Docker及Compose插件的函数
function install_Docker {

    #安装docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    
    #安装 Compose CLI 插件：
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

    #测试安装。
    docker compose version
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
    "  2、UfW防火墙管理"
    "  3、强制更新脚本"
    "——————————————————————————————————"
    "  4、Docker及Composeg管理"
    "  5、Warp服务"
    "  6、安装\更新X-ui面板（x-ui指令打开面板）"
    "  7、V2ray服务"
    "——————————————————————————————————"
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
    "  2、安装Nginx"
    "  3、从github下载更新配置文件"
    "  4、从github下载更新网页文件"
    "  5、修改Nginx配置"
    "  6、申请SSL证书"
    "  7、查看Nginx配置文件"
    "  8、查看网页文件根目录"
    "  9、停止运行Nginx"
    "  10、卸载"
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
    #一级菜单136选项
        1 | 3 | 6)
            case $option in
                1) change_ssh_port
                   change_login_password;;
                3) update "force";;
                4) install_Docker;;
                6) bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh);;
            esac
            wait;;
     #一级菜单234选项
       2 | 4 | 5 | 7)
            
            get_option=$option
            
            while true; do
               case $get_option in
               
                 #一级菜单2选项
                 2) Option ${main_menu[$(($get_option - 1))]} "${Nginx_menu[@]}"
                    case $option in
                           2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10)
                               case $option in
                                   2)install_nginx;;
                                   3)download_nginx_config;;
                                   4)download_html;;
                                   5)set_nginx_config;;
                                   6)apply_ssl_certificate;;
                                   7)nano /etc/nginx/conf.d/default.conf;;
                                   8)ls /var/www/html;;
                                   9)stop "nginx";;
                                   10)echo "没开发呢！";;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                    esac;;
                    
                 #一级菜单4选项
                 2) Option ${main_menu[$(($get_option - 1))]} "${Docker_menu[@]}"
                    case $option in
                           2 | 3 |)
                               case $option in
                                   2)install_docker;;
                                   3)echo "没开发呢！";;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                    esac;;
                        
                  #一级菜单3选项
                  3)Option ${main_menu[$(($get_option - 1))]} "${V2ray_menu[@]}" 
                        case $option in
                            2 | 3 | 4 | 5 | 6 | 7)
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
                  4) Option ${main_menu[$(($get_option - 1))]} "${Warp_menu[@]}" 
                        case $option in
                           2 | 3 | 4)
                               case $option in
                                   2)install_warp;;
                                   3);;
                                   4)echo "没开发呢！";;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                        esac;;
                        
                       #一级菜单7选项 
                  7) Option ${main_menu[$(($get_option - 1))]} "${other_menu[@]}" 
                        case $option in
                           2)
                               case $option in
                                   2)stop "ufw";;
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

