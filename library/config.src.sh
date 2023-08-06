#############################################################################################################################################################################################
##############################################################################    用户数据及应用配置管理模块  ################################################################################################
############################################################################################################################################################################################
##此模块依赖library/text_processing.scr.sh模块，且必须置于其他配置程序前面
### 菜单栏
config_menu=(
    "返回上一级"               "return"
    "修改个人配置参数"          "set_dat"
    "查看配置参数文件"          'nano "$configfile_path"; continue'
    "备份个人配置文件"          'confirm "是否备份个人配置文件，并覆盖原有备份？" "已取消备份配置" || ( cp "$configfile_path" "$configfile_path.bak"; echo "已备份个人配置" )'
    "恢复个人配置文件"          'confirm "是否恢复个人配置文件，并覆盖现有配置？" "已取消恢复配置" || ( cp "$configfile_path.bak" "$configfile_path"; echo "已恢复备份配置" )'
    "查看备份配置参数文件"       'nano "$configfile_path.bak"; continue'
    )
    
####### 定义路径及  ######
configfile_path="$data_path/$def_name.dat"                                                       #配置数据文件路径


## 配置文件模板头部 ##
configfile_mod='
# 该文件为vinci用户配置文本
# * 表示不可在脚本中修改的常量,变量值需要用双引号包围
# 第一个#@后为：变量名称
# 第一个#@后为：备注
# 第三个#@后为：匹配规则（有条件规则和比较规则）。1、比较规则：即为正则表达式的变量名（请注意，不是正则表达本身，需要在arg中定义正则表达式），输入结果将与该正则表达式作比较。2、条件规则：为判断new_text变量是否符合规则条件，条件需用两个双引号包裹
config_num="\"${#configfile_mod}\""                         #配置模板版本号*              
$(pz "Domain")                                          #@一级域名#@不用加www#@domain_regex
'

## 添加配置文件内容 
function adddat { 
     eval "$(eval echo "\"$1"\")" || quit "添加配置模板错误，请检查格式！" "${BASH_SOURCE[0]}" "${FUNCNAME[0]}" "${FUNCNAME[1]}"
     configfile_mod+="$1" 
}

function pz { 
     echo "$1=\"$(eval echo \$"$1")\""      #将参数X变成 X=$X值的的形式
} 

#######   创建\更新用户配置数据模板    #######
function update_dat { 
    if ! source $configfile_path >/dev/null 2>&1; then   #读取用户数据
        echo "系统无用户数据记录。准备新建用户数据..."
        #配置文件具象化
        eval configfile_mod="\"$configfile_mod\"" || quit "添加配置模板错误，请检查格式！" "${BASH_SOURCE[0]}" "${FUNCNAME[0]}" "${FUNCNAME[1]}"
        echo "$configfile_mod" > "$configfile_path"  #写入数据文件
        echo "初始化数据完成"
        wait
    else
        if ! [[ "$config_num" == "${#configfile_mod}" ]] ; then
           echo "配置文件更新中..."
           eval config_all="\"$configfile_mod\"" || quit "添加配置模板错误，请检查格式！即将退出" "${BASH_SOURCE[0]}" "${FUNCNAME[0]}" "${FUNCNAME[1]}"
           echo "$config_all" > "$configfile_path" #写入数据文件
           echo "更新完成，可在系统设置中修改参数！"
           wait
        fi
    fi
}

#######   修改数据      #######   
function set_dat { 
  #如果指定配置，则指定修改
    if ! [ $# -eq 0 ]; then
         for arg in "$@"; do
             line=$(search "#@" '' "$arg" 1 false false false true "$configfile_path" )            
             IFS=$'\n' readarray -t a <<< $(echo "$line" | sed 's/#@/\n/g') # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。这里的IFS不在while循环中执行，所以用readarray -t a 会一行一行地读取输入，并将每行数据保存为数组 a 的一个元素。-t 选项会移除每行数据末尾的换行符。空行也会被读取，并作为数组的一个元素。
             rule="$(echo -e "${a[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"   #去除规则前后的空格
             if [ -z "$rule" ]; then
             :      #如果是空的，则无需进行判断句的判断
             #判断rule是否为正则表达式,如果是正则表达式变量名则转换为条件规则语句
             elif ! [[ "${rule:0:1}" == '"' && "${rule: -1}" == '"' ]]; then   
                 rule="${!rule}" 
             fi 
             settext "\"" "\"" "$arg" 1 true false false true "$configfile_path" "${a[0]}" "${a[1]}" 1 "$rule" 
         done         
    else
    
    #如果没有指定配置，则全文修改
    lines=()
    while IFS= read -r line; do   # IFS用于指定分隔符，IFS= read -r line 的含义是：在没有任何字段分隔符的情况下（即将IFS设置为空），读取一整行内容并赋值给变量line。与下面的IFS不同，这个命令在一个 while 循环中执行，每次循环都会读取 line1 中的一行，直到 line1 中的所有行都被读取完毕。
         if [[ ! $line =~ "=" ]] || [[ $line =~ ^([[:space:]]*[#]+|[#]+) ]] || [[ $line =~ \*([[:space:]]*|$) ]] ; then continue ; fi  #跳过#开头和*结尾的行
         lines+=("$line")    #将每行文本转化为数组     
    done < "$configfile_path"
    
    # 因为在上面含有IFS= read的循环中，没法再次read到用户的输入数据，因此在循环外处理数据
    for line in "${lines[@]}"; do   
         a=()
         IFS=$'\n' readarray -t a <<< $(echo "$line" | sed 's/#@/\n/g') # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。这里的IFS不在while循环中执行，所以用readarray -t a 会一行一行地读取输入，并将每行数据保存为数组 a 的一个元素。-t 选项会移除每行数据末尾的换行符。空行也会被读取，并作为数组的一个元素。
         IFS="=" read -ra b <<< "$line" 
         rule="$(echo -e "${a[3]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"   #去除规则前后的空格
         if [ -z "$rule" ]; then   #如果是空的，则无需进行判断句的判断
             :      
         elif ! [[ "${rule:0:1}" == '"' && "${rule: -1}" == '"' ]]; then   #判断rule是正则表达式变量名还是条件语句,如果是正则表达式变量名则转换为条件语句
             rule=${!rule}   
         fi
         settext "${b[0]}=\"" '"' "" 1 true false false true "$configfile_path" "${a[1]}" "${a[2]}" 1 "$rule" 
    done
    fi
    source "$configfile_path"   #重新载入数据
    echo
    echo "已修改配置完毕！"
}

#######  应用配置更新   #######   
function update_config {
    lines=()
    local ct=0      #已修改配置的数量
    local ft=0      #修改失败的数量
    while IFS= read -r line; do     
         lines+=("$line")    #将每行文本转化为数组     
    done < "$1" 

    for index in "${!lines[@]}"; do   
         line1=${lines[$index]}
         linenum=$((index+1))            #配置行号
         line2=${lines[$linenum]}
         [[ "$line1" == *'#￥#@'* ]] || continue      #如果没有找到参数行，则继续查找
         [[ "$line2" =~ ^[[:space:]]*# ]] && continue      #如果配置行是注释行，则继续查找
         a=()
         IFS=$'\n' readarray -t a <<< $(echo "$line1" | sed 's/#@/\n/g')    # IFS不可以处理两个字符的分隔符，所以将 #@ 替换为换行符，并用IFS分隔。
         varname="$(echo -e "${a[4]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"   #去除变量名的前后空格
         echo 
         #如果变量存在
         if [ -v $varname ]; then
            echo "已将配置由：$line2"
            lines[$linenum]=$(replace "${a[2]}" "${a[3]}" "" 1 false false false false "${line2}"  "${!varname}")
            echo -e "更新为：${BLUE}${lines[$linenum]}${NC}"
            echo
            ct=$(( ct + 1 ))
            
         #如果变量不存在
         else
            echo -e "${RED}配置修改失败：$line2${NC}"
            echo -e "${RED}用户数据中未找到${a[1]}的变量名：$varname${NC}"
            echo
            ft=$(( ft + 1 ))
         fi
    done
        if (( ct > 0 )); then
           printf "%s\n" "${lines[@]}" > "$1"
           echo -e "${BLUE}已完成$ct条配置的修改更新${NC}"
           echo -e "${RED}有$ft条配置更新失败${NC}"
           return 0
        else
           echo -e "${RED}配置更新失败，未找到配置行或配置值！${NC}"
           return 1
        fi
} 

