
#############################################################################################################################################################################################
##############################################################################   15.Chatgpt—Docker  ################################################################################################
############################################################################################################################################################################################
######   参数配置   ######
Version=1.00  #版本号  

adddat '
#####Chatgpt-docker######
$(pz "Gpt_port")                              #@Chatgpt本地端口#@0-65535#@port_regex 
$(pz "Chatgpt_api_key")                        #@Chatgpt Api
$(pz "Gpt_code")                               #@授权码
$(pz "Proxy_model")                           #@接口代理模式#@1为正向代理、2为反向代理#@\"[[ \$new_text =~ ^(1|2)\$ ]]\"
$(pz "BASE_URL")                               #@OpenAI接口代理URL#@默认接口为https://api.openai.com#@web_regex
$(pz "PROXY_URL")                              #@Chatgpt本地代理地址#@需要加http前缀#@web_regex
Chatgpt_image=\"yidadaa/chatgpt-next-web\"       #Chat镜像名称*
Chatgpt_name=\"chatgpt\"                                    #Chat容器名称*
'
##### 菜单栏 #####
gpt_menu=(
    "下载\更新Chatgpt"                 "pull_gpt"
    "启动\重启动Chatgpt"               "docker start $Chatgpt_name"
    "运行\重运行Chatgpt容器"            "run_gpt"
    "设置Chatgpt配置"                  "set_gpt"
    "查看Chatgpt运行状况"               'docker inspect $Chatgpt_name'
    "停用Chatgpt"                     'confirm "是否停止运行Chatgpt？" "已取消！" || docker stop $Chatgpt_name'
    )                     


######  下载 chatgpt-next-web 镜像 ######
function pull_gpt {
docker pull yidadaa/chatgpt-next-web
}

######  运行chatgpt-next-web 镜像 ######
function run_gpt {
    docker stop $Chatgpt_name >/dev/null 2>&1 && echo "正在重置chatgpt容器..."
    docker rm $Chatgpt_name >/dev/null 2>&1
    if (( Proxy_model==1 )); then 
        if docker run -d --name $Chatgpt_name --restart=always -p 3000:$Gpt_port \
           -e OPENAI_API_KEY="$Chatgpt_api_key" \
           -e CODE="$Gpt_code" \
           --net=host \
           -e PROXY_URL="$PROXY_URL" \
           $Chatgpt_image
       then
           echo "Chatgpt启动成功！"
       else 
        echo "启动失败，请重新设置参数配置"
       fi  
    elif (( Proxy_model==2 )); then 
        if docker run -d  --name $Chatgpt_name --restart=always -p 3000:$Gpt_port \
           -e OPENAI_API_KEY="$Chatgpt_api_key" \
           -e CODE="$Gpt_code" \
           -e BASE_URL="$BASE_URL" \
           $Chatgpt_image
       then
           echo "Chatgpt启动成功！"
       else 
        echo "启动失败，请重新设置参数配置"
       fi  

    fi
}

######  设置chatgpt配置 ######
function set_gpt {
local conf=(
"Gpt_code"
"Chatgpt_api_key"
"Gpt_port"
"Proxy_model"
"BASE_URL"
"PROXY_URL" 
)
    set_dat ${conf[@]}
    if confirm "是否启动Chatgpt并适用最新配置？" "已取消启动"; then return; fi
    run_gpt
}
