#!/bin/bash

# 设置变量
email="15555@qq.com"
domain="16666.com"
api_key="177777"

# 获取区域标识符
zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$domain" \
     -H "X-Auth-Email: $email" \
     -H "X-Auth-Key: $api_key" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

# 如果区域标识符为空，则表示未找到该域名
if [ "$zone_identifier" == "null" ]; then
    echo "在您的Cloudflare账户中未找到该域名。"
else
    # 显示所有DNS解析记录
    dns_records=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A" \
         -H "X-Auth-Email: $email" \
         -H "X-Auth-Key: $api_key" \
         -H "Content-Type: application/json" | jq -r '.result[] | [.name, .content] | @tsv')
    echo "所有DNS解析记录："
    echo "$dns_records"

    # 询问用户要进行的操作
    echo "请选择要进行的操作："
    echo "1. 删除DNS记录"
    echo "2. 修改或增加DNS记录"
    read choice

    if [ "$choice" == "1" ]; then
        # 删除DNS记录
        echo "请输入要删除的DNS记录名称（例如 www）："
        read record_name

        # 获取记录标识符
        record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name.$domain" \
             -H "X-Auth-Email: $email" \
             -H "X-Auth-Key: $api_key" \
             -H "Content-Type: application/json" | jq -r '.result[0].id')

        # 如果记录标识符为空，则表示未找到该记录
        if [ "$record_identifier" == "null" ]; then
            echo "未找到该DNS记录。"
        else
            # 删除记录
            curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                 -H "X-Auth-Email: $email" \
                 -H "X-Auth-Key: $api_key" \
                 -H "Content-Type: application/json"
            echo "已成功删除记录 $record_name.$domain"
        fi
    elif [ "$choice" == "2" ]; then
        # 修改或增加DNS记录
        echo "请输入要修改或增加的DNS记录名称（例如 www）："
        read record_name

        # 验证IP地址
        ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
        while true; do
            echo "请输入IP地址："
            read record_content

            if [[ $record_content =~ $ip_regex ]]; then
                break
            else
                echo "无效的IP地址，请重试。"
            fi
        done

        echo "是否启用Cloudflare CDN代理？（Y/N）"
        read enable_proxy
        if [[ $enable_proxy =~ ^[Yy]$ ]]; then
            proxy="true"
        else
            proxy="false"
        fi

            # 获取记录标识符
            record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A&name=$record_name.$domain" \
                 -H "X-Auth-Email: $email" \
                 -H "X-Auth-Key: $api_key" \
                 -H "Content-Type: application/json" | jq -r '.result[0].id')

            # 如果记录标识符为空，则创建新记录
            if [ "$record_identifier" == "null" ]; then
                curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
                     -H "X-Auth-Email: $email" \
                     -H "X-Auth-Key: $api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo "已成功添加记录 $record_name.$domain"
            else
                # 如果记录标识符不为空，则更新现有记录
                curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
                     -H "X-Auth-Email: $email" \
                     -H "X-Auth-Key: $api_key" \
                     -H "Content-Type: application/json" \
                     --data '{"type":"A","name":"'"$record_name"'","content":"'"$record_content"'","proxied":'"$proxy"'}'
                echo "已成功更新记录 $record_name.$domain"
                
                # 显示所有DNS解析记录
                dns_records=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A" \
                     -H "X-Auth-Email: $email" \
                     -H "X-Auth-Key: $api_key" \
                     -H "Content-Type: application/json" | jq -r '.result[] | [.name, .content] | @tsv')
                echo "最新DNS解析记录："
                echo "$dns_records"
           fi
    fi
fi
