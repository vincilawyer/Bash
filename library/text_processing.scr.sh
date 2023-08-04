#############################################################################################################################################################################################
##############################################################################    文本和输入管理模块  ################################################################################################
############################################################################################################################################################################################
####### 定义全局变量  ######                                  
old_text=""   #settext函数修改前内容
new_text=""   #inp函数输入的内容

#######   查询文本内容   #######   
function search {
  local start_string="$1"           # 开始文本字符串
  local end_string="$2"             # 结束文本字符串
  local location_string="$3"        # 定位字符串
  local n="${4:-1}"                 # 要输出的匹配结果的索引
  local exact_match="${5:-True}"    # 是否精确匹配结束文本字符串
  local module="${6:-True}"         # 是否在一段代码内寻找定位字符串，false为行内寻找
  local comment="${7:-True}"        # 是否显示注释行
  local is_file="${8:-True}"        # 是否为文件
  local input="$9"                  # 要搜索的内容
  local found_text=""               # 存储找到的文本
  local count=0                     # 匹配计数器
  
  #定义awk的脚本代码
  local awk_script='{
    if($0 ~ location || (mod && mat) ) {
      mat="true"
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
                      if (end == "" ) {
                         print substr($0, startPos + length(start)) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      } else {
                         print substr($0, startPos + length(start), endPos - 1) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      }
                      exit;
                  }    
              } else {  
                  if (++count == num) {  # 输出第 n 个匹配结果
                      print substr($0, startPos + length(start)) ((match($0, /^[[:space:]]*#/) ? " (注释行)" : ""));
                      exit;
                                        }
              }
           }  
      }
    }
  }'
  
  if [ "$is_file" = "true" ]; then    #如果输入的是文件
    found_text=$(awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module" -v exact="$exact_match" -v num="$n" "$awk_script" "$input")
  else   #如果输入的是字符串
    found_text=$(echo "$input" | awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module" -v exact="$exact_match" -v num="$n" "$awk_script")
  fi

  if ! $comment; then found_text=${found_text// (注释行)/}; fi
  echo "$found_text"   # 输出找到的文本
}

#######   替换文本内容   #######   
function replace() {
  local start_string="$1"         # 开始文本字符串
  local end_string="$2"           # 结束文本字符串
  local location_string="$3"      # 定位字符串
  local n="${4:-1}"               # 匹配结果的索引
  local exact_match="${5:-True}"  # 是否精确匹配
  local module="${6:-True}"       # 是否在一段代码内寻找定位字符串，false为行内寻找
  local comment="${7:-fasle}"     # 是否修改注释行
  local is_file="${8:-True}"      # 是否为文件
  local input="$9"                # 要替换的内容
  local input_text="${10}"          # 替换的新文本
  local temp_file="$(mktemp)"
    
  #定义awk的脚本代码
  local awk_script='{
    if($0 ~ location || (mod && mat) ) {
        mat="true"
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
                                   match(line, /^[ #]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/#/, "", s)
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
                                   match(line, /^[ #]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/#/, "", s)
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
                                   match(line, /^[ #]*/)
                                   s = substr(line, RSTART, RLENGTH)
                                   gsub(/#/, "", s)
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
      }  else {
           print $0;
      }
}'

  if [ "$is_file" = "true" ]; then    #如果输入的是文件
      awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module" -v exact="$exact_match" -v new="$input_text" -v comment="$comment" -v num="$n" "$awk_script" "$input" > "$temp_file"
      mv "$temp_file" "$input"
  else   #如果输入的是字符串
      temp_text=$(echo "$input" | awk -v start="$start_string" -v end="$end_string" -v location="$location_string"  -v mod="$module"  -v exact="$exact_match" -v new="$input_text" -v comment="$comment" -v num="$n" "$awk_script")
      echo "$temp_text"   # 输出替换的内容
  fi
}  

#######   修改文本对话框   #######   
function settext {
  local start_string="$1"         # 开始文本字符串
  local end_string="$2"           # 结束文本字符串
  local location_string="$3"      # 定位字符串
  local n="${4:-1}"               # 匹配结果的索引            
  local exact_match="${5:-True}"  # 是否精确匹配结束文本字符串
  local module="${6:-True}"       # 是否在一段代码内寻找定位字符串，false为行内寻找
  local comment="${7:-fasle}"     # 是否修改注释行,false模式下，输入#则内容替换为空字符。输入为"#"，则为#
  local is_file="${8:-True}"      # 是否为文件
  local input="$9"                # 要替换的内容
  local mean="${10}"              # 显示搜索和修改内容的含义
  local mark="${11}"              # 修改内容备注
  #          ${@:12}              # 匹配规则，参照inp函数
  local temp_file="$(mktemp)"
  old_text=""                     # 设置搜中的旧文本作为全局变量（不含“注释行”字样）
  new_text=""                     # 设置输入的新文本作为全局变量（不含前后空格）

     old_text1=$(search "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "true" "$is_file" "$input")
     old_text=${old_text1// (注释行)/}
     echo
     echo -e "${BLUE}【"$mean"设置】${NC}${GREEN}当前的"$mean"为$([ -z "$old_text1" ] && echo "空" || echo "：$old_text1")${NC}"
     while true; do
         #-r选项告诉read命令不要对反斜杠进行转义，避免误解用户输入。-e选项启用反向搜索功能，这样用户在输入时可以通过向左箭头键或Ctrl + B键来移动光标并修改输入。
         echo -ne "${GREEN}请设置新的$mean（$( [ -n "$mark" ] && echo "$mark,")输入为空则跳过$( [[ $coment == "true" ]] && echo "，输入#则设为注释行" || echo "，输入#则设为空值" )）：${NC}"
         inp true ${@:12} $( [ -n "${13}" ] && echo "#" )  
         if [[ -z "$new_text" ]]; then
             echo -e "${GREEN}已跳过$mean设置${NC}"
             return 1
         else    
            if  [[ $is_file == "true" ]]; then   #如果在文件模式下
                 if [[ "$new_text" == "#" ]] && [[ $comment == "true" ]]; then
                     replace "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "$comment" "$is_file" "$input" "$new_text"
                     echo -e "${BLUE}已将"$mean"参数设为注释行${NC}"
                     return 0
                 else
                     [[ "$new_text" == "#" ]] && new_text=""
                     [[ "$new_text" == '"#"' ]] && new_text="#"
                     replace  "$start_string" "$end_string" "$location_string" "$n" "$exact_match" "$module" "$comment" "$is_file" "$input" "$new_text"
                     echo -e "${BLUE}"$mean"已修改为"$([ -z "$new_text" ] && echo "空" || echo "：$new_text")"${NC}"
                     return 0
                 fi
            else                           #如果在文本模式下

               :
            fi
         fi
     done  
}    

#######   输入框    ####### 
#说明：1、传入的第一个参数为true则能接受回车输入，第一个参数为false则不能回车输入。参数带有""号字符，则将参数视为具体条件语句，没有""则为普通比较。
#     2、传入的第二个参数为比较模式，1为正则表达式匹配，2为字符串普通匹配。两种模式下，都可以使用条件语句。
#     其余参数均为比较参数
function inp {
    tput sc
    local k="true" #判断参数是否全部为空
    while true; do
        new_text=""
        read new_text
        [ $1 = true ] && [[ -z "$new_text" ]] && tput el && return   #如果$1为true，且输入为空，则完成输入
        for Condition in "${@:3}"; do
           #如果参数为空则继续下一个参数
           [[ -z $Condition ]] && continue   
           k="false"
           # 检查参数是否为条件语句
           if [[ "${Condition:0:1}" == '"' && "${Condition: -1}" == '"' ]]; then   #注意-1前面有空格
                if eval ${Condition:1:-1}; then tput el && return; fi
           # 如果参数为普通字符串
           else
               if [ "$2" == "1" ]; then
                  [[  $new_text =~ $Condition ]] && tput el && return
               elif [ "$2" == "2" ]; then
                  [[ "$new_text" == "$Condition" ]] && tput el && return
               fi
           fi
        done
        [ "$k" == "true" ] && tput el && return
        tput rc
        tput el
        echo
        echo -e "${RED} 输入不正确，请重新输入！${NC}"
        tput rc
   done
}

#######  插入文本 ######
function insert {
    local argtext="$1"           # 参数内容
    local config="$2"           # 配置内容
    local location_string="$3"     #匹配的内容
    local file="$4"                #文件位置
    local findloc=0                #文件中是否找到一个带注释符的匹配内容    
    local lineno=0                 #行号
    local lines=()
    while IFS= read -r line;do
         ((lineno++)) #记住行号
         if [[ $line =~ $location_string ]]; then
              #如果行首不是注释符
              if ! [[ $line =~ ^[[:space:]]*# ]]; then
                  # 插入注释符，并插入新字符串到下一行
                  sed -i "${lineno}s/^/#该行系由vinci脚本修改，原内容为： /" "$file"
                  sed -i "${lineno}a\\$config" "$file"
                  sed -i "${lineno}a\\$argtext" "$file"
                  return
                  
              #如果行首是注释符
              else
                  ((findloc==0)) && findloc=$lineno && continue
                  #如果这不是唯一一行的注释符
                  findloc=0
                  break  
              fi
         fi
    done < "$file"    
    if ! ((findloc==0)); then
       sed -i "${findloc}s/^/#该行系由vinci脚本修改，原内容为： /" "$file"
       sed -i "${findloc}a\\$config" "$file"
       sed -i "${findloc}a\\$argtext" "$file"
       return
    fi
    #如果没找到匹配内容或唯一带有注释匹配内容
    sed -i "${lineno}a\\$config" "$file"
    sed -i "${lineno}a\\$argtext" "$file"
}

#######   是否确认框    #######   
function confirm {
   read -p "$1（Y/N）:" confirm1
   if [[ $confirm1 =~ ^[Yy]$ ]]; then 
   return 1
   fi  
   echo $2
   return 0
}
