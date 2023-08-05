############################################################################################################################################################################################
##############################################################################   vinci脚本主程序源代码   ########################################################################################
############################################################################################################################################################################################
####### 版本更新相关参数 ######
Version=4.00  #版本号 
Version1="$Version.$(n="$(cat "$path_def")" &&  echo "${#n}")"                         #脚本完整版本号


####### 各配置路径及文件名  ######
#基本参数
#library > arg.lib
path_arg="$data_path/arg.lib"
link_arg="${link_repositories}library/arg.lib"

#文本处理
#library > text_processing.scr.sh
path_text_processing="$data_path/text_processing.scr.sh"
link_text_processing="${link_repositories}library/text_processing.scr.sh"

#页面显示
#library > page.src.sh
path_page="$data_path/page.src.sh"
link_page="${link_repositories}library/page.src.sh"

#用户配置
#library > config.src.sh
path_config="$data_path/config.src.sh"
link_config="${link_repositories}library/config.src.sh"

#通用工具
#toolbox > universal.src.sh
path_toolbox_universal="$data_path/universal.src.sh"
link_toolbox_universal="${link_repositories}vinci/toolbox/universal.src.sh"

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
##############################################################################    Debian11系统UI   ########################################################################################
############################################################################################################################################################################################
if uname -a | grep -q 'Debian'; then 
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
    echo "               欢迎进入Vinci服务器管理系统(版本V$Version1)"
    echo
}
###### 菜单标题 ######
function menutitle {
    echo "=========================== "$1" =============================="
    echo
}
############################################################################################################################################################################################
##############################################################################    Android系统UI   ########################################################################################
############################################################################################################################################################################################
elif uname -a | grep -q 'Android'; then 
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
    echo "     欢迎进入Vinci服务器管理系统(版本V$Version1)"
    echo
}
###### 菜单标题 ######
function menutitle {
    echo "================= "$1" ====================="
    echo
}
############################################################################################################################################################################################
##############################################################################    MAC系统UI   ########################################################################################
############################################################################################################################################################################################
elif uname -a | grep -q 'Darwin'; then 
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
    echo "               欢迎进入Vinci服务器管理系统(版本V$Version1)"
    echo
}
###### 菜单标题 ######
function menutitle {
    echo "=========================== "$1" =============================="
    echo
}

############################################################################################################################################################################################
##############################################################################     其他   ########################################################################################
############################################################################################################################################################################################
else 
echo "当前为未识别系统，未定义UI"
sleep 3
fi


############################################################################################################################################################################################
##############################################################################    Debian11系统加载模块及菜单   ########################################################################################
############################################################################################################################################################################################
function Initial {
if uname -a | grep -q 'Debian'; then 
    echo
    echo -e "${GREEN}已载入主程序，进行Debian端模块配置...${NC}"
    #判断系统适配  
    if [ ! $(lsb_release -rs) = "11" ]; then 
        echo "请注意，本脚本是适用于Vulre服务器Debian11系统，用于其他系统或版本时将可能出错！"
        wait
    fi
    
    #载入通用模块
    update_load "$path_arg" "$link_arg" "基本参数模块" 1 "$startcode" 
    update_load "$path_text_processing" "$link_text_processing" "文本处理模块" 1 "$startcode" 
    update_load "$path_page" "$link_page" "页面显示模块" 1 "$startcode" 
    update_load "$path_config" "$link_config" "用户配置模块" 1 "$startcode" 
    update_load "$path_toolbox_universal" "$link_toolbox_universal" "通用工具模块" 1 "$startcode" 
    #载入专属模块
    update_load "$path_toolbox_linux" "$link_toolbox_linux" "linux工具模块" 1 "$startcode" 
    update_load "$path_appmanage" "$link_appmanage" "程序管理模块" 1 "$startcode" 
    update_load "$path_docker" "$link_docker" "docker" 1 "$startcode" 
    update_load "$path_nginx" "$link_nginx" "nginx" 1 "$startcode" 
    update_load "$path_xui" "$link_xui" "xui" 1 "$startcode" 
    update_load "$path_cf" "$link_cf" "cloudflare" 1 "$startcode" 
    update_load "$path_tor" "$link_tor" "tor" 1 "$startcode" 
    update_load "$path_frp" "$link_frp" "frp" 1 "$startcode" 
    update_load "$path_chatgpt" "$link_chatgpt" "chatgpt" 1 "$startcode" 
    update_load "$path_alist_linux" "$link_alist_linux" "alist_linux" 1 "$startcode" 
    update_load "$path_rclone_linux" "$link_rclone_linux" "rclone_linux" 1 "$startcode"  
    ((startcode==1)) && (echo -n "更新检查完成，即将进入程序..." ; countdown 5)

#### 主菜单 ####
main_menu=(
    "系统设置"              'page true " 系 统 设 置 " "${system_menu[@]}"'
    "UFW防火墙管理"          'page true " UFW 防 火 墙" "${ufw_menu[@]}"'
    "Docker服务"            'page true "Docker" "${docker_menu[@]}"'
    "Nginx服务"             'page true "Nginx" "${nginx_menu[@]}"'
    "X-ui服务"              'page true "X-UI" "${xui_menu[@]}"'
    "Cloudflare服务"        'page true "Cloudflare" "${cf_menu[@]}"'
    "Tor服务"               'page true "Tor" "${tor_menu[@]}"'
    "Frp服务"               'page true "Frp" "${frp_menu[@]}"'
    "Chatgpt-Docker服务"   'page true "Chatgpt-Docker" "${gpt_menu[@]}"'
    "Alist服务"            'page true "Alist" "${alist_menu[@]}"'
    "Rclone服务"            'page true "Rclone" "${rclone_menu[@]}"'
    )
    
### 系统工具选项 ###
system_menu=(
    "返回上一级"                "return"
    "查看所有重要程序运行状态"    "status_all"
    "本机ip信息"               "ipinfo"
    "修改配置参数"              "set_dat"
    "查看配置参数文件"           "nano /root/myfile/vinci.dat"
    "修改SSH登录端口和登录密码"   "change_ssh_port; change_login_password"
    "更新脚本"                  'startcode=1; base_load; Initial; continue'
     )  

############################################################################################################################################################################################
##############################################################################    Android系统加载模块及菜单   ########################################################################################
############################################################################################################################################################################################
elif uname -a | grep -q 'Android'; then 
    echo
    echo -e "${GREEN}已载入主程序，进行Android端模块配置...${NC}""
    
    #载入通用模块
    update_load "$path_arg" "$link_arg" "基本参数模块" 1 "$startcode" 
    update_load "$path_text_processing" "$link_text_processing" "文本处理模块" 1 "$startcode" 
    update_load "$path_page" "$link_page" "页面显示模块" 1 "$startcode" 
    update_load "$path_config" "$link_config" "用户配置模块" 1 "$startcode" 
    update_load "$path_toolbox_universal" "$link_toolbox_universal" "通用工具模块" 1 "$startcode" 
    ######载入专属模块 ######
    update_load "$path_alist_andriod" "$link_alist_andriod" "alist_andriod" 1 "$startcode" 
    update_load "$path_rclone_andriod" "$link_rclone_andriod" "rclone_andriod" 1 "$startcode" 
    ((startcode==1)) && (echo -n "更新检查完成，即将进入程序..." ; countdown 5)

main_menu=(
    "系统设置"              'page true " 系 统 设 置 " "${system_menu[@]}"' 
    "Alist服务"            'page true "Alist" "${alist_menu[@]}"'
    "Rclone服务"            'page true "Rclone" "${rclone_menu[@]}"'
    )
system_menu=(
    "返回上一级"                "return"
    "修改配置参数"              "set_dat"
    "查看配置参数文件"           "nano /root/myfile/vinci.dat"
    "更新脚本"                  'startcode=1; base_load; Initial; continue'
    )  


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
##############################################################################     mac加载模块及菜单   ########################################################################################
############################################################################################################################################################################################
elif uname -a | grep -q 'Darwin'; then 
    echo
    echo -e "${GREEN}已载入主程序，进行Mac端模块配置...${NC}"
    
    #载入通用模块
    update_load "$path_arg" "$link_arg" "基本参数模块" 1 "$startcode" 
    update_load "$path_text_processing" "$link_text_processing" "文本处理模块" 1 "$startcode" 
    update_load "$path_page" "$link_page" "页面显示模块" 1 "$startcode" 
    update_load "$path_config" "$link_config" "用户配置模块" 1 "$startcode" 
    update_load "$path_toolbox_universal" "$link_toolbox_universal" "通用工具模块" 1 "$startcode" 
    ######载入专属模块 ######
    update_load "$path_alist_andriod" "$link_alist_andriod" "alist_andriod" 1 "$startcode" 
    update_load "$path_rclone_andriod" "$link_rclone_andriod" "rclone_andriod" 1 "$startcode" 
    ((startcode==1)) && (echo -n "更新检查完成，即将进入程序..." ; countdown 5)

main_menu=(
    "系统设置"              'page true " 系 统 设 置 " "${system_menu[@]}"' 
    "Alist服务"            'page true "Alist" "${alist_menu[@]}"'
    "Rclone服务"            'page true "Rclone" "${rclone_menu[@]}"'
    )
system_menu=(
    "返回上一级"                "return"
    "修改配置参数"              "set_dat"
    "查看配置参数文件"           "nano /root/myfile/vinci.dat"
    "Mac终端网络代理模式"         'export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;export ALL_PROXY=socks5://127.0.0.1:1086; echo "已启动终端网络代理！"'
    "更新脚本"                  'startcode=1; base_load; Initial; continue'
    )  


############################################################################################################################################################################################
##############################################################################     其他加载模块及菜单   ########################################################################################
############################################################################################################################################################################################
else
   echo '未知系统...拒绝加载'
   quit
fi; }

function main {
   Initial
   #检查用户数据文件 
   clear
   update_dat 
  
   #显示一级菜单主页面
   page false ' 主 菜 单 ' "${main_menu[@]}"          
}
