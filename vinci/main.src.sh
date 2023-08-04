############################################################################################################################################################################################
##############################################################################   vinci脚本主程序源代码   ########################################################################################
############################################################################################################################################################################################
####### 版本更新相关参数 ######
Version=4.00  #版本号 
Version1="$Version.$(n="$(cat "$path_def")" &&  echo "${#n}")"                         #脚本完整版本号


####### 各配置路径及文件名  ######
#基本参数
#library > arg.lib
path="$data_path/arg.lib"
link="${link_repositories}library/arg.lib"
update_load "$path" "$link" "基本参数模块" 1 true
#文本处理
#library > text_processing.scr.sh
path="$data_path/text_processing.scr.sh"
link="${link_repositories}library/text_processing.scr.sh"
update_load "$path" "$link" "文本处理模块" 1 true
#页面显示
#library > page.src.sh
path="$data_path/page.src.sh"
link="${link_repositories}library/page.src.sh"
update_load "$path" "$link" "页面显示模块" 1 true
#用户配置
#library > config.src.sh
path="$data_path/config.src.sh"
link="${link_repositories}library/config.src.sh"
update_load "$path" "$link" "用户配置模块" 1 true
#通用工具
#toolbox > universal.src.sh
path="$data_path/universal.src.sh"
link="${link_repositories}vinci/toolbox/universal.src.sh"
update_load "$path" "$link" "通用工具模块" 1 true

#linux工具
#toolbox > linux.src.sh
path_toolbox_linux="$data_path/linux.src.sh"
link_toolbox_linux="${link_repositories}vinci/toolbox/linux.src.sh"

#appmanage.src.sh
#app > appmanage.src.sh
path_appmanage="$data_path/appmanage.src.sh"
link_appmanage="${link_repositories}vinci/application/appmanage.src.sh"

#xui
#app > xui.src.sh
path_xui="$data_path/xui.src.sh"
link_xui="${link_repositories}vinci/application/xui.src.sh"

#tor.src.sh
#app > tor.src.sh
path_tor="$data_path/tor.src.sh"
link_tor="${link_repositories}vinci/application/tor.src.sh"

#nginx
#app > nginx.scr.sh
path_nginx="$data_path/nginx.scr.sh"
link_nginx="${link_repositories}vinci/application/nginx.scr.sh"

#frp
#app > frp.scr.sh
path_frp="$data_path/frp.scr.sh"
link_frp="${link_repositories}vinci/application/frp.scr.sh"

#cf
#app > cloudflare.scr.sh
path_cf="$data_path/cloudflare.scr.sh"
link_cf="${link_repositories}vinci/application/cloudflare.scr.sh"

#rclone_linux
#app > rclone_linux.src.sh
path_rclone_linux="$data_path/rclone_linux.src.sh"
link_rclone_linux="${link_repositories}vinci/application/rclone/rclone_linux.src.sh"

#rclone_andriod
#app > rclone_andriod.src.sh
path_rclone_andriod="$data_path/rclone_andriod.src.sh"
link_rclone_andriod="${link_repositories}vinci/application/rclone/rclone_andriod.src.sh"

#alist_linux
#app > alist_linux.src.sh
path_alist_linux="$data_path/alist_linux.src.sh"
link_alist_linux="${link_repositories}vinci/application/alist/alist_linux.src.sh"

#alist_andriod
#app > alist_andriod.src.sh
path_alist_andriod="$data_path/alist_andriod.src.sh"
link_alist_andriod="${link_repositories}vinci/application/alist/alist_andriod.src.sh"

#docker
#app > docker.src.sh
path_docker="$data_path/docker.src.sh"
link_docker="${link_repositories}vinci/application/docker/docker.src.sh"

#chatgpt
#app > chatgpt_docker.src.sh
path_chatgpt="$data_path/chatgpt_docker.src.sh"
link_chatgpt="${link_repositories}vinci/application/docker/chatgpt_docker.src.sh"



############################################################################################################################################################################################
##############################################################################    Debian11系统   ########################################################################################
############################################################################################################################################################################################
if uname -a | grep -q 'Debian'; then 
    echo '检测系统为Debian，正在配置中...' 
    #判断系统适配  
    if [ ! $(lsb_release -rs) = "11" ]; then 
        echo "请注意，本脚本是适用于Vulre服务器Debian11系统，用于其他系统或版本时将可能出错！"
        wait
    fi
    
###### 页面logo ######
function logo {
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
    echo; echo -e "${RED}${art}${NC}"; echo; echo
}

###### 页面标题 ######
function pagetitle {
    echo "                欢迎进入Vinci服务器管理系统(版本V$Version1)"
    echo
}
###### 菜单标题 ######
function menutitle {
    echo "=========================== "$1" =============================="
    echo
}

######载入模块 ######
update_load "$path_toolbox_linux" "$link_toolbox_linux" "linux工具模块" 1 false
update_load "$path_docker" "$link_docker" "docker" 1 false
update_load "$path_nginx" "$link_nginx" "nginx" 1 false
update_load "$path_xui" "$link_xui" "xui" 1 false
update_load "$path_cf" "$link_cf" "cloudflare" 1 false
update_load "$path_tor" "$link_tor" "tor" 1 false
update_load "$path_frp" "$link_frp" "" 1 false
update_load "$path_chatgpt" "$link_chatgpt" "chatgpt" 1 false
update_load "$path_alist_linux" "$link_alist_linux" "alist_linux" 1 false
update_load "$path_rclone_linux" "$link_rclone_linux" "rclone_linux" 1 false

#### 主菜单 ####
main_menu=(
    "  1、系统设置"              'page true " 系 统 设 置 " "${system_menu[@]}"'
    "  2、UFW防火墙管理"          'page true " UFW 防 火 墙" "${ufw_menu[@]}"'
    "  3、Docker服务"            'page true "Docker" "${docker_menu[@]}"'
    "  4、Nginx服务"             'page true "Nginx" "${nginx_menu[@]}"'
    "  5、X-ui服务"              'page true "X-UI" "${xui_menu[@]}"'
    "  6、Cloudflare服务"        'page true "Cloudflare" "${cf_menu[@]}"'
    "  7、Tor服务"               'page true "Tor" "${tor_menu[@]}"'
    "  8、Frp服务"               'page true "Frp" "${frp_menu[@]}"'
    "  9、Chatgpt-Docker服务"   'page true "Chatgpt-Docker" "${gpt_menu[@]}"'
    "  10、Alist服务"            'page true "Alist" "${alist_menu[@]}"'
    "  11、Rclone服务"            'page true "Rclone" "${rclone_menu[@]}"'
    "  0、退出")
    
### 系统工具选项 ###
system_menu=(
    "  1、返回上一级"                "return"
    "  2、查看所有重要程序运行状态"    "status_all"
    "  3、本机ip信息"               "ipinfo"
    "  4、修改配置参数"              "set_dat"
    "  5、查看配置参数文件"           "nano /root/myfile/vinci.dat"
    "  6、修改SSH登录端口和登录密码"   "change_ssh_port; change_login_password"
    "  7、更新脚本"                  'echo "维护"'
    "  0、退出" )  

############################################################################################################################################################################################
##############################################################################    Android系统   ########################################################################################
############################################################################################################################################################################################
elif uname -a | grep -q 'Android'; then 
    echo '检测系统为Android，正在配置中...'

###### 页面logo ######
function logo {
art=$(cat << "EOF"
  __     __                         _   _                     
  \ \   /"/u          ___          | \ |"|           
    \ \ / //          |_"_|        <|  \| |>      
    /\ V /_,-.         | |         U| |\  |u          
   U  \_/-(_/        U/| |\u        |_| \_|    
     //           .-,_|___|_,-.     ||   \\,-.     
    (__)           \_)-' '-(_/      (_")  (_/

EOF
)
    echo; echo -e "${RED}${art}${NC}"; echo; echo
}

###### 页面标题 ######
function pagetitle {
    echo "       欢迎进入Vinci服务器管理系统(版本V$Version1)"
    echo
}
###### 菜单标题 ######
function menutitle {
    echo "=================== "$1" ======================="
    echo
}

######载入模块 ######
update_load "$path_alist_andriod" "$link_alist_andriod" "alist_linux" 1 false
update_load "$path_rclone_andriod" "$link_rclone_andriod" "rclone_linux" 1 false


main_menu=(
    "  1、系统设置"              'page true " 系 统 设 置 " "${system_menu[@]}"' 
    "  2、Alist服务"            'page true "Alist" "${alist_menu[@]}"'
    "  3、Rclone服务"            'page true "Rclone" "${rclone_menu[@]}"'
    "  0、退出")
system_menu=(
    "  1、返回上一级"                "return"
    "  2、修改配置参数"              "set_dat"
    "  3、查看配置参数文件"           "nano /root/myfile/vinci.dat"
    "  4、更新脚本"                  'echo "维护"'
    "  0、退出" )  


#初始化安卓配件
function InitialAndroid {
   # 检查是否已安装 ncurses-utils
   if ! command -v tput &> /dev/null; then
      echo "ncurses-utils未安装. Start installing..."
      pkg upgrade; pkg update; pkg install ncurses-utils -y
   fi
}
InitialAndroid

############################################################################################################################################################################################
##############################################################################     其他   ########################################################################################
############################################################################################################################################################################################
else 
   echo '未知系统...拒绝加载'
   quit
fi


function main {
   #检查用户数据文件 
   clear
   update_dat 
  
   #显示一级菜单主页面
   page false ' 主 菜 单 ' "${main_menu[@]}"          
}
