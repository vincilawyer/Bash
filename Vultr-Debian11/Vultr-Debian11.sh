#!/bin/bash

#版本号,不得为空
Version=2.41
dat_Version=1

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
#用户选择序号                                     
option=""
#修改前内容
text1=""
#修改后内容
text2=""

#刷新等待时长
  Standby=50        
#更新检查程序网址
  link_update="https://raw.githubusercontent.com/vincilawyer/Bash/main/install-bash.sh"
#用户数据路径
  dat_path="/usr/local/bin/vinci.dat"
#nginx配置文件网址
  link_nginx="https://raw.githubusercontent.com/vincilawyer/Bash/main/nginx/default.conf"
#ssh配置文件路径(查看配置：nano /etc/ssh/sshd_config)                           
  path_ssh="/etc/ssh/sshd_config"
#nginx配置文件路径 (查看配置：nano /etc/nginx/conf.d/default.conf)                      
  path_nginx="/etc/nginx/conf.d/default.conf" 
#nginx日志文件路径
  log_nginx="/var/log/nginx/access.log"
#nginx 80端口默认服务块文件路径
  default_nginx="/etc/nginx/sites-enabled/default"
#tor路径 (查看配置：nano /etc/tor/torrc)            
  path_tor="/etc/tor/torrc"
#frp配置文件路径（查看配置：nano /etc/frp/frps.ini）  
  path_frp="/etc/frp"

#一级域名正则表达式
domain_regex="^[a-zA-Z0-9-]{1,63}(\.[a-zA-Z]{2,})$"
#二级域名正则表达式
subdomain_regex="^[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$"
#邮箱表正则表达式
email_regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
#IPV4表达式
ipv4_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
#IPV6表达式
ipv6_regex="^([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])$"
#ip端口号表达式
port_regex="^([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
#大陆手机11位手机号表达式
tel_regex="^1[3-9]\d{9}$"
#若干#和空格前置的表达式 
comment_regex="^ *[# ]*"





                                                                          #更新函数
function update {
    clear && current_Version="$1" bash <(curl -s -L -H 'Cache-Control: no-cache' $link_update)
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

                                                                          # 创建用户数据
dat_path="/usr/local/bin/vinci.dat"
function creat_dat {
cat > $dat_path <<EOF
# "*"表示不可在脚本中修改的常量,变量值需要用双引号包围,"#@"用于分隔变量名称、备注、匹配正则表达式。
*dat_Version1="1"             #@版本号              
Domain="domain.com"           #@一级域名#@不用加www#@domain_regex
Email="email@email.com"       #@邮箱#@#@email_regex
#Cloudflare_api_key="abc"      #@Cloudflare Api
Chatgpt_api_key="abc"         #@Chatgpt Api
EOF
}

                                                                          # 设置数据
function set_dat {
    while IFS= read -r line   # IFS用于指定分隔符，IFS= read -r line 的含义是：在没有任何字段分隔符的情况下（即将IFS设置为空），读取一整行内容并赋值给变量line
    do
         if [[ $line =~ ^([[:space:]]*[#*]+|[#*]+) ]] ; then continue ; fi  #跳过有注释符和常量符的变量
         IFS='#@' read -a a <<< "$line"    #找出变量名称及正则表达式
         set """ """ 1 $line true "${a[2]}" "${a[3]}" false
    done < "$dat_path"
}
#creat_dat
#set_dat

                                                                          # 创建用户数据
#function creat_dat {
# awk '{
    
 # if ($0 ~ /^([[:space:]]*[#*]+|[#*]+)/) {next} #跳过有注释符和常量符的变量
  #    split($0, a, "#@");    #找出变量注释
   #   gsub(/^ *| *$/, "", a[2]);   #剔除注释前后空格
    #           a[2]="${a[2]#"${a[2]%%[![:space:]]*}"}"
     #    a[2]="${a[2]%"${a[2]##*[![:space:]]}"}"

   #   print a[2];

 #   }' $dat_path 
#}
                                                                          #查询文本内容函数

function search {
  local start_string="$1"           # 开始文本字符串
  local end_string="$2"             # 结束文本字符串
  local n="${3:-1}"                 # 要输出的匹配结果的索引
  local exact_match="${4:-True}"    # 是否精确匹配
  local comment="${5:-True}"        # 是否显示注释行
  local is_file="${6:-True}"        # 是否为文件
  local input="$7"                  # 要搜索的内容
  local found_text=""               # 存储找到的文本
  local count=0                     # 匹配计数器
  
  #定义awk的脚本代码
  local awk_script='{
      if (exact == "true") {
          startPos = index($0, start);
          if (startPos > 0) {
          endPos = index(substr($0, startPos + length(start)), end);
              if (endPos > 0) {
                  if (++count == num) {
                      print substr($0, startPos + length(start), endPos - 1) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      exit;
                  }
              }
          }
      } else {
            startPos = index($0, start);
            if (startPos > 0) {
              endPos = index(substr($0, startPos + length(start)), end);
              if (endPos > 0) {
                  if (++count == num) {
                      print substr($0, startPos + length(start), endPos - 1) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      exit;
                  }    
              } else {  
                  if (++count == num) {  # 输出第 n 个匹配结果
                      print substr($0, RSTART + length(start)) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      exit;
                  }
              }
           }
      }
  }'
  
  if [ "$is_file" = "true" ]; then    #如果输入的是文件
    found_text=$(awk -v start="$start_string" -v end="$end_string" -v exact="$exact_match" -v num="$n" "$awk_script" "$input")
  else   #如果输入的是字符串
    found_text=$(echo "$input" | awk -v start="$start_string" -v end="$end_string" -v exact="$exact_match" -v num="$n" "$awk_script")
  fi
  
  if ! $comment; then found_text=${found_text// (注释行)/}; fi
  echo "$found_text"   # 输出找到的文本
}

                                                                          #改变文本内容函数

function replace() {
  local start_string="$1"         # 开始文本字符串
  local end_string="$2"           # 结束文本字符串
  local n="${3:-1}"               # 匹配结果的索引            
  local exact_match="${4:-True}"  # 是否精确匹配
  local comment="${5:-fasle}"     # 是否修改注释行
  local is_file="${6:-True}"      # 是否为文件
  local input="$7"                # 要替换的内容
  local new_text="$8"             # 替换的新文本
  local temp_file="$(mktemp)"
    
  #定义awk的脚本代码
  local awk_script='{
        if (exact == "true") {
             startPos = index($0, start);
             if (startPos > 0) {
                 endPos = index(substr($0, startPos + length(start)), end);
                  if (endPos > 0) {
                      if (++count == num) {
                          if (comment == "true"  && new == "#" ) {
                              print "#" $0 
                          } else {
                              starttext = substr($0, 1 , startPos - 1 + length(start) );
                              endtext = substr($0, startPos + length(start) + endPos - 1 );
                              line = starttext new endtext;
                              if (comment == "true") {
                                   match(line, /^[ \#]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/\#/, "", s)
                                   line = s substr(line, RLENGTH + 1)
                              }
                              print line;
                          }
                      } else {
                       print $0;
                      }
                  } else {
                       print $0;
                  }
             } else {
                 print $0;
             }
        } else {
             startPos = index($0, start);
             if (startPos > 0) {
                 endPos = index(substr($0, startPos + length(start)), end);
                  if (endPos > 0) {
                      if (++count == num) {
                          if (comment == "true"  && new == "#" ) {
                              print "#" $0 
                          } else {
                              starttext = substr($0, 1 , startPos - 1 + length(start) );
                              endtext = substr($0, startPos + length(start) + endPos - 1 );
                              line = starttext new endtext;
                              if (comment == "true") {
                                   match(line, /^[ \#]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/\#/, "", s)
                                   line = s substr(line, RLENGTH + 1)
                              }
                              print line;
                          }
                      } else {
                       print $0;
                      }
                  } else {
                      if (++count == num) {
                          if (comment == "true"  && new == "#" ) {
                              print "#" $0 
                          } else {
                              starttext = substr($0, 1 , startPos - 1 + length(start) );
                              line = starttext new;
                              if (comment == "true") {
                                   match(line, /^[ \#]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/\#/, "", s)
                                   line = s substr(line, RLENGTH + 1)
                              }
                              print line;
                          }                      
                      } else {
                       print $0;
                      }
                  }
             } else {
                 print $0;
             }        
        }         
    }'

  if [ "$is_file" = "true" ]; then    #如果输入的是文件
      awk -v start="$start_string" -v end="$end_string" -v exact="$exact_match" -v new="$new_text" -v comment="$comment" -v num="$n" "$awk_script" "$input" > "$temp_file"
      mv "$temp_file" "$input"
  else   #如果输入的是字符串
      temp_text=$(echo "$input" | awk -v start="$start_string" -v end="$end_string" -v exact="$exact_match" -v new="$new_text" -v comment="$comment" -v num="$n" "$awk_script")
      echo "$found_temp"   # 输出替换的内容
  fi
}  

                                                                          #查询并修改文本函数

function set {
  local start_string="$1"         # 开始文本字符串
  local end_string="$2"           # 结束文本字符串
  local n="${3:-1}"               # 匹配结果的索引            
  local exact_match="${4:-True}"  # 是否精确匹配
  local comment="${5:-fasle}"     # 是否修改注释行
  local is_file="${6:-True}"      # 是否为文件
  local input="$7"                # 要替换的内容
  local mean="$8"                 # 显示搜索和修改内容的含义
  local mark="$9"                 # 修改内容备注
  local regex="$10"              # 正则表达式
  local regex1="${11:-fasle}"     # 内容与正则表达式的真假匹配
  local temp_file="$(mktemp)"
  
     text1=""
     text2=""
     text1=$(search "$start_string" "$end_string" "$n" "$exact_match" "true" "$is_file" "$input")
     echo
     echo -e "${GREEN}当前的$mean为：$text1${NC}"
     while true; do
         #-r选项告诉read命令不要对反斜杠进行转义，避免误解用户输入。-e选项启用反向搜索功能，这样用户在输入时可以通过向左箭头键或Ctrl + B键来移动光标并修改输入。
         read -r -e -p "$(echo -e ${BLUE}"请设置新的$mean（$mark输入为空则跳过，#则设为注释行）：${NC}")" text2
         #s/^[[:space:]]*//表示将输入字符串中开头的任何空格字符替换为空字符串；s/[[:space:]]*$//表示将输入字符串结尾的任何空格字符替换为空字符串。
         text2="$(echo -e "${text2}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
         if [[ -z "$text2" ]]; then
             echo -e "${RED}已跳过$mean设置${NC}"
             return 1
         elif [[ $text2 == "#" ]] && [[ $comment == "true" ]]; then
             repalce "$start_string" "$end_string" "$n" "$exact_match" "$is_file" "$input" "$comment" "$text2"
             echo -e "${GREEN}已将$mean参数设为注释行${NC}"
             return 1
         elif [[ $text2 =~ $regex ]]; then
                replace  "$start_string" "$end_string" "$n" "$exact_match" "$comment" "$is_file" "$input" "$text2"
                echo -e "${GREEN}$mean已修改为$text2${NC}"
         else
                echo -e "${RED}$mean输入错误，请重新输入${NC}"
         fi
     done  
}

                                                                          #修改SSH端口及登录密码的函数
function change_ssh_port {
    
    if set "Port " " " 1 false true true $path_ssh "SSH端口" "0-65535，"  $port_regex; then
          echo -e "${GREEN}已正从防火墙规则中删除原SSH端口号：${text1// (注释行)/}${NC}"
          ufw delete allow ${text1// (注释行)/}/tcp   
          echo -e "${GREEN}正在将新端口添加进防火墙规则中。${NC}"
          ufw allow $text2/tcp  
          systemctl restart sshd
          echo -e "${GREEN}当前防火墙运行规则及状态为：${NC}"
          ufw status
    fi  
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
  if [ -x "$(command -v docker)" ]; then
        echo -e "${GREEN}Docker已经安装，无需重复安装。当前版本号为 $(docker -v 2>&1)${NC}"
  else
    # 安装docker，具体在https://docs.docker.com/engine/install/debian/中查看说明教程
    # 卸载冲突包
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
    
    # 更新apt包索引并安装包以允许apt通过 HTTPS 使用存储库：
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg

    #添加Docker官方GPG密钥：
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    #使用以下命令设置存储库：
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    #更新apt包索引：
    sudo apt-get update
    #安装最新版本 Docker 引擎、containerd 和 Docker Compose。
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    #通过运行镜像来验证Docker Engine安装是否成功。
    if docker run hello-world; then echo "Docker安装成功！" ; fi
  fi   
}

                                                                         # 安装Nginx_Proxy_Manager的函数
function install_Nginx_PM {
   echo "维护中"
   return
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
        echo -e "${GREEN}正在调整防火墙规则，放开80、443端口。${NC}"
        ufw allow http && ufw allow https 
        echo -e "${GREEN}正在调整Nginx配置${NC}"
        download_nginx_config
        #清空nginx对80端口默认服务块的配置内容
cat > $default_nginx <<EOF
        
EOF
    fi
}

                                                                           # 从github下载更新Nginx配置文件
function download_nginx_config {
    if choose "是否从Github下载更新Nginx配置文件？此举动将覆盖原配置文件" "已取消下载更新Nginx配置文件"; then return;fi
         echo -e "${GREEN}正在载入：${NC}"
         if wget $link_nginx -O $path_nginx; then 
            echo -e "${GREEN}载入完毕，第一次使用请设置配置：${NC}"
            set_nginx_config
         else
            echo -e "${GREEN}下载失败，请检查！${NC}"
         fi       
}
                                                                           # 设置Nginx配置
function set_nginx_config {
     # echo "维护中，请手动导入配置！"
     #  return
       if ! [ -x "$(command -v nginx)" ]; then
          echo -e "${RED}Nginx尚未安装，请先进行安装！${NC}"
       fi
       current_domain=$(search "server_name " ";" 1 $path_nginx true false)
       set "ssl_certificate " "/$current_domain" 1 $path_nginx true "SSL证书存放路径"
       current_ssl_path=$(search "ssl_certificate " "$current_domain" 1 $path_nginx true false)
       if set "server_name " ";" 1 $path_nginx true "VPS域名" "" true "^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$"; then
           replace  "$current_ssl_path" ".cer;" 1 "$text2" $path_nginx true
           replace  "$current_ssl_path" ".key;" 1 "$text2" $path_nginx true
       fi
       if set "https://" "; #伪装网址" 1 $path_nginx true "伪装域名" "" true "^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$"; then
           replace  "sub_filter \"" "\"" 1 "$text2" $path_nginx true
           replace  "proxy_set_header Host \"" "\"" 1 "$text2" $path_nginx true
       fi
       set "location /ray-" " {" 1 $path_nginx true "xray分流路径" "省略/ray-前缀，"
       set "http://127.0.0.1:" "; #Xray端口" 1 $path_nginx true "Xray监听端口" "0-65535，" true "^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
       set "location /xui-" " {" 1 $path_nginx true "x-ui面板分流路径" "省略/xui-前缀，"
       set "http://127.0.0.1:" "; #xui端口" 1 $path_nginx true "X-ui监听端口" "0-65535，" true "^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
       echo "正在重启Nginx..."
       if nginx -t &> /dev/null; then
          systemctl restart nginx
          return
       fi
       echo "Nginx配置文件存在错误，请检查并修改后重启！"
}   
                                                                            # 从github下载网页文件
function download_html {
   echo "维护中..."
   return
   if choose "此操作将从Github的vincilawyer/Bash/nginx/html目录下载入网页文件，并覆盖原网页文件！" "已取消下载更新网页文件"; then return;fi
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
       path_html=$(search "root" " ")
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
   echo "维护中"
   return
    # 输入域名
    while true; do
        read -p "$(echo -e ${BLUE}"请输入申请SSL证书域名（不加www.）: ${NC}")" domain_name
        if [[ -z $domain_name ]]; then
          echo -e "${RED}未输入域名，退出申请操作${NC}"
          return
        elif [[ $domain_name =~ ^[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$ ]]; then
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
    certbot certonly --standalone --agree-tos -n -d $domain_name -m $email
    
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
   echo "维护中"
   return
    domain_name="$1"
    ssl_path="$2"
    #搜索SSL证书
    search_result=$(find "$2/" -name fullchain.pem -print0 | xargs -0 grep -l "$domain_name" 2>/dev/null)
    if [[ -z "$search_result" ]]; then
      return false
    else
      return true
    fi
}

                                                                          # 安装Warp并启动Warp的函数
function install_Warp {

    if [ -x "$(command -v warp-cli)" ]; then
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
   if [ -x "$(command -v x-ui)" ]; then
        echo -e "${GREEN}X-ui面板已安装，无需重复安装！${NC}"      
   else
        bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
   fi
}
                                                                          # 安装Tor的函数
function install_Tor {
   if [ -x "$(command -v tor)" ]; then
        echo -e "${GREEN}Tor已安装，无需重复安装！${NC}"      
   else
        echo -e "${GREEN}正在更新包列表${NC}"
        sudo apt update
        echo -e "${GREEN}开始安装Tor${NC}"
        apt install tor -y
   fi
}
                                                                           # 设置Tor配置
function set_tor_config {
   set "SocksPort " " " 2 "false" "true" "true" $path_tor "Tor监听端口" "0-65535，" $port_regex
}
                                                                           # 获取Tor ip
function ip_tor {
  text1=$(search "SocksPort " " " 2 "false" "false" "true" $path_tor )
  echo "当前Tor代理IP为："
  curl --socks5-hostname localhost:$text1 http://ip-api.com/line/?fields=status,country,regionName,city,query
  echo
}
  
  
                                                                          # 安装Frp的函数
function install_Frp {
   if [ -x "$(command -v frps)" ]; then 
        echo -e "${GREEN}Frp已安装，无需重复安装！${NC}"   
   else
        # 获取最新的 frp 版本
        version=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep 'tag_name' | cut -d\" -f4)
        # 获取Linux amd64版本的tar.gz文件名
        file_name=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | jq -r '.assets[] | select(.name | contains("linux_amd64")) | .name')
        # 下载最新版本的 frp
        wget https://github.com/fatedier/frp/releases/download/$version/$file_name
        # 解压下载的文件
        tar -xvzf $file_name
        rm $file_name
        
        # 把frps加入systemd
        mv $(echo $file_name | sed 's/.tar.gz//')/frps /usr/bin/
        mkdir -p $path_frp
        mv $(echo $file_name | sed 's/.tar.gz//')/frps.ini $path_frp
        rm -r $(echo $file_name | sed 's/.tar.gz//')
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
   fi
}
function reset_Frp {
if choose "是否重置Frp配置" "已取消重置！"; then return;fi 
cat > $path_frp/frps.ini <<EOF
[common]
# 服务端监听端口
bind_port = 8888
# HTTP 类型代理监听的端口（给Nginx反向代理用）
vhost_http_port = 10080
vhost_https_port = 10443
# 鉴权使用的 token 值
token = 88888888
#服务端仪表板端口
dashboard_port = 21211
#仪表板登录用户名
dashboard_user = admin
#仪表板登录密码
dashboard_pwd = admin
EOF
}



                                                                          # 安装CF_DNS的函数
function install_CF_DNS {
    if choose "是否从Github下载更新CF_DNS脚本文件？此举动将覆盖原脚本文件。" "已取消下载更新CF_DNS脚本文件"; then return; fi
    #安装jq
    echo "正在安装依赖软件JQ..."
    if [ -x "$(command -v jq)" ]; then
        echo -e "${GREEN}JQ已安装，无需重复安装！${NC}"      
    else
        apt update
        apt install jq -y
    fi
    echo -e "${GREEN}正在下载CF_DNS脚本文件：${NC}"
    wget $link_cfdns -O $path_cfdns
    chmod +x $path_cfdns 

}
                                                                          # 修改CF_DNS配置的函数
function set_CF_config {
#维护中
    if ! [ -e "$path_cfdns" ]; then
        echo "CF_DNS脚本尚未安装，请先安装！"
        return
    fi
    set 'email="' '"' 1 $path_cfdns "true" "true" "Cloudfare账户邮箱" "" true "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    set 'domain="' '"' 1 $path_cfdns true "Cloudfare绑定域名" "不加www等前缀，" true "^[a-z0-9]+(-[a-z0-9]+)*\.[a-z]{2,}$"
    set 'api_key="' '"' 1 $path_cfdns true "Cloudfare API密钥"
    chmod +x $path_cfdns
}


                                                                          # 一键搭建服务端的函数
function one_step {
   if choose "是否一键搭建科学上网服务端？" "已取消一键搭建科学上网服务端"; then return;fi
   echo "正在安装X-ui面板"
   install_Xui
   wait "点击任意键安装Nginx"
   install_Nginx
   wait "点击任意键安装Warp"
   install_Warp
   echo "请：
   1、在x-ui中自行申请SSL
   2、在x-ui面板中调整xray模板、面板设置，并创建节点"
}
function restart {
   echo "正在重启$1..."
   systemctl restart "$1"
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
   if [[ -z "$1" ]]; then
    echo "请按下任意键返回管理系统"
   else
    echo $1
   fi
   read -n 1 -s input
}
                                                                         # 定义选择取消函数
function choose {
   read -p "$1（Y/N）:" choose1
   if [[ $choose1 =~ ^[Yy]$ ]]; then 
   return 1
   fi  
   echo $2
   return 0
}

                                                                         # 定义选择功能错误函数
function error_option {
       echo -e "${RED}输入不正确，请重新输入${NC}"
       countdown 1
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
  clear
  if [ "$option" == "0" ]; then
      exit 0
  fi
  echo
}


# 定义菜单选项
    main_menu=(
    "  1、修改SSH登录端口和登录密码"
    "  2、UFW防火墙管理"
    "  3、强制更新脚本
—————————————————————————————————————"
    "  4、一键搭建科学上网服务端"
    "  5、Docker服务"
    "  6、Nginx服务"
    "  7、Warp服务"
    "  8、X-ui服务"
    "  9、Tor服务"
    "  10、Frp服务"
    "  11、CF-DNS脚本" 
    "  12、Chatgpt-Docker服务"
"—————————————————————————————————————  
  0、退出"
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
    "  2、安装Docker"
    "  0、退出"   
    )
    
    Nginx_menu=(
    "  1、返回上一级"
    "  2、安装Nginx Proxy Manager"
    "  3、安装Nginx"
    "  4、使用Certbot申请SSL证书"
    "  5、从github下载更新配置文件"
    "  6、设置Nginx配置（第一次使用需设置）"
    "  7、重启Nginx"
    "  8、查看Nginx日志"
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
    "  0、退出"
    )
    Tor_menu=(
    "  1、返回上一级"
    "  2、安装Tor"
    "  3、设置Tor配置（第一次使用需设置）"
    "  4、重启Tor"
    "  5、IP信息"
    "  0、退出"
    )
    Frp_menu=(
    "  1、返回上一级"
    "  2、安装Frp"
    "  3、初始化Frp配置"
    "  4、设置Frp配置"
    "  5、重启Frp"
    "  0、退出"
    )
    Cf_DNS_menu=(
    "  1、返回上一级"
    "  2、启动Cf_DNS脚本面板"
    "  3、下载\更新CF_DNS脚本"
    "  4、设置脚本配置（第一次使用需设置）"
    "  0、退出"
    )
    Chatgpt_menu=(
    "  1、返回上一级"
    "  2、启动Chatgpt"
    "  3、查看Chatgpt运行状态"
    "  4、Chatgpt更新脚本"
    "  0、退出"
    )


                                                                           # 主函数
function main {
  #判断系统是否适配
  if [ ! $(lsb_release -rs) = "11" ]; then 
  echo "请注意，本脚本是适用于Vulre服务器Debian11系统，用于其他系统或版本时将可能出错！"
  wait;
  fi

  #检查用户数据文件是否存在及更新
#  if source $dat_path; then   #读取用户数据
 #   echo "未找到配置文件，正在重新创建！"
  #  creat_dat
   # set_dat
  #fi
  
  
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
                4) one_step ;;
            esac
            wait;;
            
     #一级菜单2、5、6至12选项
       2 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12)
       
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
                           2)
                               case $option in
                                   2)install_Docker;;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                    esac;;

    
                  #一级菜单6 Nginx选项
                 6) Option ${main_menu[$(($get_option - 1))]} "${Nginx_menu[@]}"
                    case $option in
                           2 | 3 | 4 | 5 | 6 | 7 | 8)
                               case $option in
                                   2)install_Nginx_PM;;
                                   3)install_Nginx;;
                                   4)apply_ssl_certificate;;
                                   5)download_nginx_config;;
                                   6)set_nginx_config;;
                                   7)restart "nginx";;
                                   8)nano /var/log/nginx/access.log;;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                    esac;;
                                            
                  #一级菜单7 Warp选项
                  7) Option ${main_menu[$(($get_option - 1))]} "${Warp_menu[@]}" 
                        case $option in
                           2)
                               case $option in
                                   2)install_Warp;;
                               esac
                               wait;;
                          1)break;;
                          *)error_option;;
                        esac;;
                        
                  #一级菜单8 Xui选项
                  8)Option ${main_menu[$(($get_option - 1))]} "${Xui_menu[@]}" 
                        case $option in
                            2 | 3)
                               case $option in
                                   2)install_Xui;;
                                   3)x-ui;;
                               esac
                               wait;;
                           1)break;;
                           *)error_option;;
                        esac;;     
                        
                  #一级菜单9 Tor选项
                  9)Option ${main_menu[$(($get_option - 1))]} "${Tor_menu[@]}" 
                        case $option in
                            2 | 3 | 4 | 5)
                               case $option in
                                   2)install_Tor;;
                                   3)set_tor_config;;
                                   4)restart "tor"
                                   ip_tor;;
                                   5)ip_tor;;
                               esac
                               wait;;
                           1)break;;
                           *)error_option;;
                        esac;; 
                        
                  #一级菜单10 Frp选项
                  10)Option ${main_menu[$(($get_option - 1))]} "${Frp_menu[@]}" 
                        case $option in
                            2 | 3 | 4 | 5)
                               case $option in
                                   2)install_Frp;;
                                   3)reset_Frp;;
                                   4)set_tor_config;;
                                   5)restart "frps";;
                               esac
                               wait;;
                           1)break;;
                           *)error_option;;
                        esac;;       
                        
                   #一级菜单11 cfdns选项
                  11)Option ${main_menu[$(($get_option - 1))]} "${Cf_DNS_menu[@]}" 
                        case $option in
                            2 | 3 | 4)
                               case $option in
                                   2)cfdns;;
                                   3)install_CF_DNS;;
                                   4)set_CF_config;;
                               esac
                               wait;;
                           1)break;;
                           *)error_option;;
                        esac;;                           
                        
                  #一级菜单12 Chatgpt选项
                  12)Option ${main_menu[$(($get_option - 1))]} "${Chatgpt_menu[@]}" 
                        case $option in
                            2 | 3 | 4)
                               case $option in
                                   2)if choose "是否启动Chatgpt？" "已取消启动Chatgpt"; then continue;fi
                                     cd ~/ChatGPT-Next-Web
                                     pm2 start chat.config.js;;
                                   3)pm2 list;;
                                   4)cd ~/ChatGPT-Next-Web
                                     chatgpt;;
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
