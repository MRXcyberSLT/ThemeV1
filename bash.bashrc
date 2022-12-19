# Command history tweaks:
# - Append history instead of overwriting
#   when shell exits.
# - When using history substitution, do not
#   exec command immediately.
# - Do not save to history commands starting
#   with space.
# - Do not save duplicated commands.
##shopt -s histappend
##shopt -s histverify
##export HISTCONTROL=ignoreboth

# Default command line prompt.
##PROMPT_DIRTRIM=2
##PS1='\[\e[0;32m\]\w\[\e[0m\] \[\e[0;97m\]\$\[\e[0m\] '

# Handles nonexistent commands.
# If user has entered command which invokes non-available
# utility, command-not-found will give a package suggestions.
##if [ -x /data/data/com.termux/files/usr/libexec/termux/command-not-found ]; then
##	command_not_found_handle() {
##		/data/data/com.termux/files/usr/libexec/termux/command-not-found "$1"
##	}
##fi

clear
echo "    Welcome to termux" | figlet -f bubble | lolcat


#!/data/data/com.termux/files/usr/bin/bash

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Fix loadavg
uptime | grep -Po "average: \K.+"| awk -F", " '{ print $1,$2,$3 }' > $tmp/loadavg

# get load averages
IFS=" " read LOAD1 LOAD5 LOAD15 <<<$(cat $tmp/loadavg)
# get free memory
IFS=" " read USED AVAIL TOTAL <<<$(free -htm | grep "Mem" | awk {'print $3,$7,$2'})
# get processes
PROCESS=$(ps -eo user=|sort|uniq -c | awk '{ print $2 " " $1 }')
PROCESS_ALL=$(echo "$PROCESS"| awk {'print $2'} | awk '{ SUM += $1} END { print SUM }')
PROCESS_ROOT=$(echo "su -c ${PROCESS}"| grep root | awk {'print $2'})
PROCESS_USER=$(echo "$PROCESS"| grep -v root | awk {'print $2'} | awk '{ SUM += $1} END { print SUM }')
# get processors
PROCESSOR_NAME=$(grep "model name" /proc/cpuinfo | cut -d ' ' -f3- | awk {'print $0'} | head -1)
PROCESSOR_COUNT=$(grep -ioP 'processor\t:' /proc/cpuinfo | wc -l)

if [[ -d /system/app/ && -d /system/priv-app ]]; then
    DISTRO="Android $(getprop ro.build.version.release)"
    MODEL="$(getprop ro.product.brand) $(getprop ro.product.model)"
fi

W="\e[0;39m"
G="\e[1;32m"
C="\e[1;36m"
P="\e[1;35m"
BOLD='\033[1m'
echo -e "
${P}${BOLD}System Info:
$C•  Versi hp     : $G$DISTRO
$C•  Merk         : $G$MODEL
$C•  Kernel       : $G$(uname -sr)

$C•  Waktu aktif  : $W$(uptime -p)
$C•  Memuat       : $G$LOAD1$W (1m), $G$LOAD5$W (5m), $G$LOAD15$W (15m)
$C•  Proses       : $G$PROCESS_USER$W (user), $G$PROCESS_ALL$W (total)

$C•  CPU          : $W$PROCESSOR_NAME ($G$PROCESSOR_COUNT$W vCPU)
$C•  Memory       : $G$USED$W used, $G$AVAIL$W avail, $G$TOTAL$W total$W

$c  ××× Dibuat oleh MisterX ×××"


#!/data/data/com.termux/files/usr/bin/bash
# config
max_usage=90
bar_width=50
# colors
white="\e[39m"
green="\e[1;92m"
red="\e[1;31m"
dim="\e[2m"
undim="\e[0m"
BOLD='\033[1m'
NC='\033[0m'
BLUE="\033[96m"
# disk usage: ignore zfs, squashfs & tmpfs
mapfile -t dfs < <(df -H -t sdcardfs -t fuse -t fuse.rclone | tail -n+2)
printf "\n${P}Disk Usage:${NC}\n"

for line in "${dfs[@]}"; do
    # get disk usage
    usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    used_width=$((($usage*$bar_width)/100))
    # color is green if usage < max_usage, else red
    if [ "${usage}" -ge "${max_usage}" ]; then
        color=$red
    else
        color=$green
    fi
    # print green/red bar until used_width
    bar="[${color}"
    for ((i=0; i<$used_width; i++)); do
        bar+="#"
    done
    # print dimmmed bar until end
    bar+="${BLUE}${dim}"
    for ((i=$used_width; i<$bar_width; i++)); do
        bar+="-"
    done
    bar+="${undim}]"
    # print usage line & bar
    echo "${line}" | awk '{ printf("%-31s%+3s used out of %+4s\n", $6, $3, $2); }' | sed -e 's/^/  /'
    echo -e "${bar}" | sed -e 's/^/  /'
done
echo
PROMPT_DIRTRIM=2
PS1='\033[1;34m\]╭───\[\033[1;31m\]≼\[\033[94m\]•×•\[\033[1;33m\] MisterX \[\033[1;34m\]✓\[\033[1;92m\]\w\[\033[1;31m\]≽
\[\033[1;34m\]╰──╼\[\033[1;31m\]✠\[\033[1;32m\] '

