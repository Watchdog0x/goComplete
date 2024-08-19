#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31mError\033[0m: You don't have permission. Please run with sudo."
    exit 1
fi

spinner() {
    local task_name="$1"
    local task_function="$2"
    local pid
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local temp_file=$(mktemp)
    
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local NC='\033[0m' 
    
    tput civis  

    $task_function > "$temp_file" 2>&1 &
    pid=$!
    

    local term_width=$(tput cols)
    local max_task_width=$((term_width - 10)) 
    
    if [ ${#task_name} -gt $max_task_width ]; then
        task_name="${task_name:0:$((max_task_width-3))}..."
    fi
    
    printf "%-*s" "$max_task_width" "$task_name"
    local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r%-*s[%s]" "$max_task_width" "$task_name" "${spin[i]}"
        i=$(( (i+1) % ${#spin[@]} ))
        sleep 0.2
    done
    
    wait $pid
    local status=$?
    
    if [ $status -eq 0 ]; then
        printf "\r%-*s[${GREEN}✓${NC}]\n" "$max_task_width" "$task_name"
    else
        printf "\r%-*s[${RED}✗${NC}]\n" "$max_task_width" "$task_name"
        local error_message=$(cat "$temp_file")
        if [ -n "$error_message" ]; then
            echo -e "${RED}Error:${NC} $error_message"
        else
            echo -e "${RED}Error:${NC} An unknown error occurred."
        fi
    fi
    
    rm "$temp_file"

    return $status
}

trap 'tput cnorm' EXIT



installing() {
    local completion_content
    local output_dir

    if command -v curl &>/dev/null; then
        completion_content=$(curl -s https://raw.githubusercontent.com/Watchdog0x/goComplete/main/go-completion.sh)
    else 
        completion_content=$(wget -qO- https://raw.githubusercontent.com/Watchdog0x/goComplete/main/go-completion.sh)
    fi 

    if [ -d "/usr/share/bash-completion/completions" ]; then
        output_dir="/usr/share/bash-completion/completions"
    else
        output_dir="/etc/bash_completion.d"
    fi

    echo "$completion_content" > "$output_dir/go"
    chmod +x "$output_dir/go"

    source ~/.bashrc
}

main() { 
    spinner "Installing Go Bash Completion" installing

    printf "\nInstallation completed successfully!\n"
}

main
