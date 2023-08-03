#############################################################################################################################################################################################
##############################################################################   Rclone  ################################################################################################
############################################################################################################################################################################################
Version=1.00  #版本号 
### 菜单栏
rclone_menu=(
    "  1、返回上一级"            "return"
    "  2、安装\更新Rclone"      'pkg upgrade; pkg update; pkg install rclone'
    "  3、Rclone配置"            'rclone config'
    "  4、将Baidu网盘书库更新至Onedrive"            'baidutoonebook'
    "  5、将Onedrive书库更新至Baidu网盘"            'onetobaidubook'
    "  6、将Baidu网盘指定文件更新至Onedrive"            'baidutoone'
    "  7、将Onedrive指定文件更新至Baidu网盘"            'onetobaidu'
    "  8、Rclone使用指引"                       'echo "指令指引";echo "列出文件夹: rclone lsd onedrive:";echo "复制文件：rclone copy";echo "同步文件：rclone sync"'
    "  0、退出")
### 配置 ####
bdbook="共享文件夹/法律电子书（持续更新）"   #百度网盘书库位置
onebook="法律书库"   #onedrive书库位置

### 将baidu同步给onedrive ###
function baidutoone {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
   read -p "请输入要同步给Onedrive的Baidu网盘文件夹路径" bdname
   read -p "请输入Onedrive保存位置路径" onename   
   echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdname 文件夹基本信息如下："
   rclone size baidu:$bdname
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onename 文件夹基本信息如下："
   rclone size onedrive:$onename
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync baidu:$bdname --header "Referer:"  --header "User-Agent:pan.baidu.com" onedrive:$onename -P   #  更改百度网盘的UA，加速作用。 --header "Referer:"  --header "User-Agent:pan.baidu.com"
   echo "同步完成..."
   notifier "baidu to one 已同步完成"
}

### 将onedrive同步给baidu ###
function onetobaidu {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
   read -p "请输入要同步给Baidu网盘的Onedrive文件夹路径" bdname
   read -p "请输入Baidu网盘保存位置路径" onename
     echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdname 文件夹基本信息如下："
   rclone size baidu:$bdname
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onename 文件夹基本信息如下："
   rclone size onedrive:$onename
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync onedrive:$onename baidu:$bdname --header "Referer:"  --header "User-Agent:pan.baidu.com" -P 
   echo "同步完成..."
   notifier "one to baidu 已同步完成"
}
### 将baidu书库给onedrive ###
function baidutoonebook {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
     echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdbook 文件夹基本信息如下："
   rclone size baidu:$bdbook
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onebook 文件夹基本信息如下："
   rclone size onedrive:$onebook
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync baidu:$bdbook --header "Referer:"  --header "User-Agent:pan.baidu.com" onedrive:$onebook -P
   echo "同步完成..."
   notifier "baidu to one 已同步完成"
}

### 将onedrive书库给baidu ###
function onetobaidubook {
   echo "请将alist关闭重启，以确保百度网盘的文件目录为最新内容..."
   wait
   echo "正在获取百度网盘文件夹基本信息..."
   echo "百度网盘 $bdbook 文件夹基本信息如下："
   rclone size baidu:$bdbook
   echo "正在获取Onedrive文件夹基本信息..."
   echo "Onedrive $onebook 文件夹基本信息如下："
   rclone size onedrive:$onebook
   notifier "网盘文件信息已获取，请返回操作系统确认！"
   if confirm "是否确认继续同步？" "已取消同步！"; then return 0; fi
   echo "同步中..."
   rclone sync onedrive:$onebook baidu:$bdbook --header "Referer:"  --header "User-Agent:pan.baidu.com" -P
   echo "同步完成..."
   notifier "one to baidu 已同步完成"
}
