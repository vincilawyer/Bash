############################################################################################################################################################################################
##############################################################################   页面及菜单管理   ########################################################################################
############################################################################################################################################################################################

function page {
   local waitcon="$1"    #确认是否等待
   local title="$2"    #页面标题
   while true; do
    
    # 清除和显示页面样式
    clear
    logo
    pagetitle
    menutitle "$2"

    array=("${@:3}")
    menu=()
    cmd=()
    n=1
    
    #分离菜单和指令
    for (( i=0; i<${#array[@]}; i++ )); do
        if (( i % 2 == 0 )) ; then
            menu+=("${array[$i]}")
            echo "  [$n]$(((n<10)) && echo " ") ${array[$i]}" 
            ((n++))
        else
            cmd+=("${array[$i]}")
        fi
    done
       echo "  [0]  退出"

    #获取菜单数量
    menunum=${#menu[@]} 
    echo
    echo -n "  请按序号选择操作: "
    inp false 1 '"[[ "$new_text" =~ ^[0-9]+$ ]] && (( $new_text >= 0 && $new_text <= '$((menunum))' ))"'
    [[ "$new_text" == "0" ]] && quit 1              #如果选择零则退出
    clear 
    eval ${cmd[$((new_text-1))]}  || ( echo "指令执行可能失败，请检查！"; waitcon="true" )
    [[ "$waitcon" == "true" ]] && wait
done
}
