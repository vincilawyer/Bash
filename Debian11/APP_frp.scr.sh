#############################################################################################################################################################################################
##############################################################################   Frp模块  ################################################################################################
############################################################################################################################################################################################
Version=1.00  #版本号  

##### 菜单栏 #####
  frp_menu=(
    "服务管理器"                 'get_Service_menu "frps"; page "Frp" "${Service_menu[@]}"'
    "安装Frp"                     "install_Frp"
    "设置Frp配置"                  "set_Frp"
    )
    
######   参数配置   ######
adddat '
#####Frps######
$(pz "bind_port")                              #@服务端监听端口#@0-65535#@port_regex 
$(pz "vhost_http_port")                        #@HTTPS监听的端口#@0-65535#@port_regex 
$(pz "token")                                   #@授权码#@数字
$(pz "dashboard_port")                           #@服务端仪表板端口#@0-65535#@port_regex 
$(pz "dashboard_user")                             #@仪表板登录用户名
$(pz "dashboard_pwd")                              #@仪表板登录密码
'

#frp配置文件路径（查看配置：nano /etc/frp/frps.ini）  
path_frp_config="/etc/frp"


###### 安装Frp的函数 ######
function install_Frp {
   installed "frps" && return 
        # 获取最新的 frp 版本
        frp_version=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep 'tag_name' | cut -d\" -f4)
        # 获取Linux amd64版本的tar.gz文件名
        file_name=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | jq -r '.assets[] | select(.name | contains("linux_amd64")) | .name')
        # 下载最新版本的 frp
        wget https://github.com/fatedier/frp/releases/download/$frp_version/$file_name
        # 解压下载的文件
        tar -xvzf $file_name
        rm $file_name
        
        # 把frps加入systemd
        mv $(echo $file_name | sed 's/.tar.gz//')/frps /usr/bin/
        mkdir -p $path_frp_config
        mv $(echo $file_name | sed 's/.tar.gz//')/frps.ini $path_frp_config
        rm -r $(echo $file_name | sed 's/.tar.gz//')
        # 注意文件中的路径
        cat > /usr/lib/systemd/system/frps.service <<EOF
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frps -c /etc/frp/frps.ini

[Install]
WantedBy=multi-user.target
EOF
        initialize_frp
}

###### 初始化Frp配置 ######
function initialize_frp {
cat > "$path_frp_config/frps.ini" <<EOF
[common]
#￥#@服务端监听端口#@= #@ #@bind_port
bind_port = 27277
#￥#@HTTP监听端口#@= #@ #@vhost_http_port
vhost_http_port = 15678
#￥#@授权值#@= #@ #@token
token = 58451920
#￥#@服务端仪表板端口#@= #@ #@dashboard_port
dashboard_port = 21211          
#￥#@仪表板登录用户名#@= #@ #@dashboard_user
dashboard_user = admin          
#￥#@仪表板登录密码#@= #@ #@dashboard_pwd
dashboard_pwd = admin          
EOF
}

###### 设置frp ######
function set_Frp {
local conf=(
"bind_port"
"vhost_http_port"
"token"
"dashboard_port"
"dashboard_user" 
"dashboard_pwd"
)
    set_dat ${conf[@]}
    if update_config "$path_frp_config/frps.ini"; then
       confirm "是否重启Frps并适用新配置？" "已取消重启！" || restart frps
    fi  
  
}
