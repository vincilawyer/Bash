############################################################################################################################################################################################
##############################################################################   vinci脚本主程序源代码   ########################################################################################
############################################################################################################################################################################################

####### 版本更新相关参数 ######
Version=4.00  #版本号 
Version1="$Version.$(n="$(cat "$path_def")" &&  echo "${#n}")"                         #脚本完整版本号

####### 各配置路径及文件名  ######
#基本参数
#library > arg.lib
path="$data_path/library/arg.lib"
link="${link_repositories}library/arg.lib"
updata_load "$path" "$link" "基本参数模块" 1 true
#文本处理
#library > text_processing.scr.sh
path="$data_path/library/text_processing.scr.sh"
link="${link_repositories}library/text_processing.scr.sh"
updata_load "$path" "$link" "文本处理模块" 1 true
#页面显示
#library > page.src.sh
path="$data_path/page.src.sh"
link="${link_repositories}library/page.src.sh"
updata_load "$path" "$link" "页面显示模块" 1 true
#用户配置
#library > page.src.sh
path="$data_path/page.src.sh"
link="${link_repositories}library/page.src.sh"
updata_load "$path" "$link" "用户配置模块" 1 true

#程序管理
#library > page.src.sh
path="$data_path/page.src.sh"
link="${link_repositories}library/page.src.sh"
updata_load "$path" "$link" "用户配置模块" 1 true

#通用工具
#toolbox > universal.src.sh
path="$data_path/toolbox/universal.src.sh"
link="${link_repositories}vinci/toolbox/universal.src.sh"
updata_load "$path" "$link" "通用工具模块" 1 true

#linux工具
#toolbox > linux.src.sh
path_toolbox_linux="$data_path/toolbox/linux.src.sh"
link_toolbox_linux="${link_repositories}vinci/toolbox/linux.src.sh"
#
#app > 
path_="$data_path/"
link_="${link_repositories}vinci/"



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
updata_load "$path_toolbox_linux" "$link_toolbox_linux" "linux工具模块" 1 false

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
    "  2、查看所有重要程序运行状态"    "status"
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
main_menu=(
    "  1、系统设置"              'page true " 系 统 设 置 " "${system_menu[@]}"'
    "  2、工具箱"                'page true " 工 具 箱 " "${toolbox_menu[@]}"'   
    "  3、Docker服务"            'page true "Docker" "${docker_menu[@]}"'
    "  4、Alist服务"            'page true "Alist" "${alist_menu[@]}"'
    "  5、Rclone服务"            'page true "Rclone" "${rclone_menu[@]}"'
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
   exit
fi


function main {
   #检查用户数据文件 
   clear
   update_dat 
  
   #显示一级菜单主页面
   page false " 主 菜 单 " "${main_menu[@]}"          
}
