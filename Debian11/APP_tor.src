#############################################################################################################################################################################################
##############################################################################   13.Tor模块  ################################################################################################
############################################################################################################################################################################################
######   参数配置   ######
Version=1.00  #版本号   
path_tor="/etc/tor/torrc"

adddat '
##### Tor ######
$(pz "Tor_port")                                  #@Tor监听端口#@0-65535#@port_regex
'
##### 菜单栏 #####
tor_menu=(
    "服务管理器"                 'get_Service_menu "tor"; page "Tor" "${Service_menu[@]}"'
    "安装Tor"                   "install_Tor"
    "设置Tor配置"                "set_tor_config"
    )

###### 安装Tor的函数 ######
function install_Tor {
    installed "tor" && return 
    echo -e "${GREEN}正在更新包列表${NC}"
    sudo apt update
    echo -e "${GREEN}开始安装Tor${NC}"
    apt install tor -y
    #设置开机自启动
    systemctl enable tor
    #配置初始化
    initialize_tor
    sleep 2
    ipinfo
}

##### 初始化tor配置 ######
function initialize_tor {
    insert "#￥#@Tor监听端口#@SocksPort #@ #@Tor_port" "SocksPort 50000 " "SocksPort " "$path_tor"
}

###### 设置Tor配置 ######
function set_tor_config {
local conf=(
"Tor_port"
)
    set_dat ${conf[@]}
    if update_config "$path_tor"; then
       confirm "是否重启tor并适用新配置？" "已取消重启！" || (restart tor && sleep 3 && ipinfo)
    fi  
}
