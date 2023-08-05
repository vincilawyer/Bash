#############################################################################################################################################################################################
##############################################################################   12.Cloudflare模块  ################################################################################################
############################################################################################################################################################################################
#依赖  config.src.sh 、 text_processing.scr.sh
Version=1.00  #版本号  
######   参数配置   ######
adddat '
##### Cloudflare ######
$(pz "CFemail")                                     #@邮箱#@#@email_regex
$(pz "Cloudflare_api_key")                          #@Cloudflare Api
$(pz "Warp_port")                                   #@Warp监听端口#@0-65535#@port_regex
'

#### 菜单栏
cf_menu=(
    "返回上一级"               "return"
    "Cloudflare DNS配置"      'cfdns; continue'
    "修改CF账户配置"           "set_cfdns"
    "下载CFWarp"              "install_Warp"
    "CFWarp程序管理器"         'get_appmanage_menu "warp-svc"; page true "CFWarp" "${appmanage_menu[@]}"'
    "CFIP优选"                'page true "CloudflareST优选" "${CFST_menu[@]}"; continue'
    ) 
    
###### Cf dns配置 ######
function cfdns {
    if ! which "jq" >/dev/null 2>&1; then
      echo "正在安装依赖软件JQ..."
      apt update
      apt install jq -y
      echo "依赖件JQ已安装完成！"
    fi
    while true; do 
    # 获取区域标识符
    zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$Domain" \
     -H "X-Auth-Email: $CFemail" \
     -H "X-Auth-Key: $Cloudflare_api_key" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')
    #如果账户不存在则退出
    if [ "$zone_identifier" == "null" ]; then
       echo "未找到您的Cloudflare账户\域名，请检查配置。"
       wait
       return
    fi
    dns_records="$(get_all_dns_records $zone_identifier)"
    echo "$dns_records"
    echo
    echo
    # 询问用户要进行的操作
    echo "  操作选项："
    echo "  1. 删除DNS记录修改或增加DNS记录"
    echo "  2. 修改或增加DNS记录"
    echo "  3. 返回"
    echo "  0. 退出"
    echo ""
    echo -n "  请选择要进行的操作：" 
    inp false 2 {0..3}
    case $new_text in  
1)#删除DNS记录 
        clear
        echo "$dns_records"
        echo
        echo
        echo -n "请输入要删除的DNS记录名称（例如 www,输入为空则跳过）："
        inp true 1 '^[a-zA-Z0-9]+'
        [ -z $new_text ] && clear && continue 
        record_name=$new_text
        # 获取记录标识符
        record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name.$Domain" \
             -H "X-Auth-Email: $CFemail" \
             -H "X-Auth-Key: $Cloudflare_api_key" \
             -H "Content-Type: application/json" | jq -r '.result[0].id')
        
        clear
        # 如果记录标识符为空，则表示未找到该记录
        if [ "$record_identifier" == "null" ]; then
            echo -e "${RED}未找到该DNS记录，请重新操作。${NC}"
            continue
        else
            # 删除记录
            curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                 -H "X-Auth-Email: $CFemail" \
                 -H "X-Auth-Key: $Cloudflare_api_key" \
                 -H "Content-Type: application/json"
            echo
            echo "已成功删除DNS记录: $record_name.$Domain"
            continue
        fi;;
2)# 修改或增加DNS记录
        clear
        echo "$dns_records"
        echo
        echo
        echo -n "请输入要修改或增加的DNS记录名称（例如 www，输入空则跳过）："
        inp true 1 '^[a-zA-Z0-9]+' &&[ -z $new_text ] && clear && continue 
        record_name="$new_text"
        echo -n "请输入要绑定ip地址（输入空则跳过,输入#则为本机IP）："
        inp true 1 "$ipv4_regex" '[ "$new_text" == "#" ]' && [ -z $new_text ] && clear && continue 
        if [ "$new_text" == "#" ]; then
           record_content=$(curl -s https://ipinfo.io/ip)
        else
           record_content="$new_text"
        fi
        read -p "是否启用Cloudflare CDN代理？（Y/N）" enable_proxy
        if [[ $enable_proxy =~ ^[Yy]$ ]]; then
            proxy="true"
        else
            proxy="false"
        fi
          
            # 获取记录标识符
            record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name.$Domain" \
                 -H "X-Auth-Email: $CFemail" \
                 -H "X-Auth-Key: $Cloudflare_api_key" \
                 -H "Content-Type: application/json" | jq -r '.result[0].id')
            clear 
            # 如果记录标识符为空，则创建新记录
            if [ "$record_identifier" == "null" ]; then
                curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
                     -H "X-Auth-Email: $CFemail" \
                     -H "X-Auth-Key: $Cloudflare_api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo
                echo "已成功添加记录 $record_name.$Domain"
                continue
            else
                # 如果记录标识符不为空，则更新现有记录
                curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $CFemail" \
                     -H "X-Auth-Key: $Cloudflare_api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo
                echo "已成功更新记录 $record_name.$Domain"
                continue
           fi;;
     3) return;;
     0) quit 0
        clear;;
  esac
  wait
  done
}

######  获取并显示所有DNS解析记录、CDN代理状态和TTL  ######
function get_all_dns_records {
    dns_records=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$1/dns_records?type=A" \
         -H "X-Auth-Email: $CFemail" \
         -H "X-Auth-Key: $Cloudflare_api_key" \
         -H "Content-Type: application/json" | jq -r '.result[] | [.name, .content, .proxied, .ttl] | @tsv')
       echo "——————————Cloudflare DNS解析编辑器V3————————————"
       echo "以下为$Domain域名当前的所有DNS解析记录："
       echo
       echo "            域名                             ip        CDN状态  TTL"
       echo "$dns_records"
}

######  设置cfDNS配置 ######
function set_cfdns {
local config=(
"Domain"
"CFemail"
"Cloudflare_api_key"
)
    set_dat "${config[@]}"
}
###### 安装cf warp套 ######
function install_Warp {
     installed "warp-cli" && return
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
}
#############################################################################################################################################################################################
##############################################################################   IP优选模块  ################################################################################################
############################################################################################################################################################################################
#配置参数
path_CFST_file="$data_name/CFST"

### 菜单栏  ####
CFST_menu=(
    "返回上一级"              "return"
    "安装CFIP优选"            "install_CFST"
    "开启CFIP优选"            'cd $path_CFST_file; $path_CFST_file/CloudflareST -n 400 -url https://www.dvbh3bhvzvavdsne7h2cds.world/download/speedtest.bin'
    "CFIP配置说明"            'cd $path_CFST_file; $path_CFST_file/CloudflareST -h; continue '
    "创建可下载CF测试文件"       'Creat_cfspeedtest'
     )

#安装IP优选
function install_CFST {

    #创建应用文件夹
    mkdir "$path_CFST_file"
    echo "已创建 $path_CFST_file 应用文件夹"
    
    #下载地址
    if uname -a | grep -q 'Debian'; then 
        link_CFST_download="https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.4/CloudflareST_linux_amd64.tar.gz"
    elif uname -a | grep -q 'Android'; then 
        link_CFST_download="https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.4/CloudflareST_linux_arm64.tar.gz"
    elif uname -a | grep -q 'Darwin'; then 
        link_CFST_download="https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.2.4/CloudflareST_darwin_amd64.zip"
    fi
    echo "开始下载..."
    curl -L "$link_CFST_download" -o "$path_CFST_file/CFST.tar.gz" || (echo "下载失败了，先翻个墙吧~"; return)
    echo "开始解压..."
    tar -zxf "$path_CFST_file/CFST.tar.gz" -C "$path_CFST_file"
    chmod +x "$path_CFST_file/CloudflareST"
    rm "$path_CFST_file/CFST.tar.gz"
cat > "$path_CFST_file/ip.text" <<EOF
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
104.16.0.0/13
104.24.0.0/14
108.162.192.0/18
131.0.72.0/22
141.101.64.0/18
162.158.0.0/15
172.64.0.0/13
173.245.48.0/20
188.114.96.0/20
190.93.240.0/20
197.234.240.0/22
198.41.128.0/17 
EOF
    echo "安装完成！"
    
}
function Creat_cfspeedtest {
    speedtest_name="speedtest.bin"
    speedtest_path="/usr/share/nginx/html/$speedtest_name"
    #创建空白大文件300m
    dd if=/dev/zero of="$speedtest_path" bs=1M count=0 seek=300 
    echo "已创建完成，请在中进行nginx配置"
}
