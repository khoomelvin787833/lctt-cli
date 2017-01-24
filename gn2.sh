#!/bin/bash
# Help To Linux'CN Translate Team
# Filename: $0 	Version: 2.0.1 	Author:jiwenkangatech@foxmail.com

# Exit the exception.
  set -e

# Check Soft whether existed.
  for git in soft
  do
 	 hash $soft >/dev/null 2>&1 || {
 	 echo "Error: $soft is not installed"
  	 exit 1
  	 }
  done

# Set Chinease Language
  LCTT_Language=$(echo $LANG)
  if [ ! $LCTT_Language = "zh_CN" ];then
    export LANG="zh_CN.UTF-8" || export LC_ALL="zh_CN.UTF-8"
    test  $? -eq 0 || { 
    echo -e "\e[1;31mPlease Check \"Chinese Support\" was install or not\e[0m\n"
    exit 1
    }
  fi 

# Get Github User detail
  read -p "Github User: " Uname
  git clone https://$Uname@github.com/$Uname/TranslateProject 
  #! Warm: Please add Key login later
  cd $PWD/TranslateProject
  echo -e "\e[1;32mlctt-cli was got ready\e[0m"
  echo -e "\n\e[1;42m Press any key to continue \e[0m"
  read && clear && echo -e '\n\n\n'

# Show the "lctttranslatemodle" file or not
  echo -e "\033[37;33;5m \
  $(cat "$(find . -inum $(ls -i |grep LCTT | \
  awk '{print $1}'))" | head -n 1)\033[39;49;0m"
  cat "$(find . -inum $(ls -i |grep LCTT | awk '{print $1}'))" | grep -vi \#

# Show the thime and Say think you
  echo -e "\e[1;33m\nWelcome, "$Uname"! "$(date "+Time Now: %T")"\e[0m\n"
  #! Warm: Later add morning afternoon

# Find File.
  if [[ -d "$PWD/../TranslateProject/sources/tech/" ]]; then
    tech="$PWD/../TranslateProject/sources/tech/"
    tech_num=$(find  $tech  -type f | grep -v README.md |  wc -l)
    echo "tech have $tech_num article."
  fi
  if [[ -d "$PWD/../TranslateProject/sources/talk/" ]]; then
    talk="$PWD/../TranslateProject/sources/talk/"
    talk_num=$(find  $talk  -type f | grep -v README.md |  wc -l)
    echo "talk have $talk_num article."
  fi

# Show File.
  echo -e "\n\e[1;42m Press any key to continue \e[0m"
  read 

  for i in translated translating fanyi 翻译
  do
  cd $talk && grep -RHi $i *| cut -d ":" -f 1 > /tmp/TranslateProject_talk.txt 
  cd $tech && grep -RHi $i *| cut -d ":" -f 1 > /tmp/TranslateProject_tech.txt
  done

  find $tech -type f |grep -v README.md |\
  grep -v "$(cat /tmp/TranslateProject_tech.txt |\
  sort -u )" > /tmp/TranslateProject.txt
  find $talk -type f |grep -v README.md |\
  grep -v "$(cat /tmp/TranslateProject_talk.txt |\
  sort -u )" >> /tmp/TranslateProject.txt

  awk -F '[..]' '{print $3,$4,$5,$6}' /tmp/TranslateProject.txt |\
  sed 's/md//g'| sed 's#^\/TranslateProject\/sources##g' | sed 'sO^[\/]'OOg |\
  sed 's/^/.\//' |  tr -d $ | sed  's/[ \s ]*$//' |\
  sed 's/$/.md/'  > /tmp/TranslateProject2.txt
  cat -n /tmp/TranslateProject2.txt | less 

# Find The Number.
  read -p "Please enter the number: " SELECT
  cd_Find_Number=$( cat /tmp/TranslateProject2.txt | sed -n "$SELECT p" | \
  cut -d / -f 2 )
  Find_Number=$(cat /tmp/TranslateProject2.txt | sed -n "$SELECT p" | xargs -0 |\
  sed -n '1p' | cut -d / -f 3 )
  echo $Find_Number

# Github -> Add file
  exec[11]=$(find . -name "$Find_Number")
  if [ "$(expr length "${exec[11]}")" -eq 0 ];then
    echo -e "\033[37;31;5mFail to Find this file,Please retry...\033[39;49;0m" 
  else 
    cd $PWD/../$cd_Find_Number
    $(sed -i "1i **translating by [$Uname](https://github.com/$Uname)**" \
	"$(find . -name "$Find_Number" | sed  's#^\.\/##')")
    git add "$(find . -name "$Find_Number" | sed  's#^\.\/##')"
    git commit -am "Translating By "$Uname" "
    git push origin master

  test $? -eq 0 && {
  echo -e "\e[1;33m   Done.\e[0m"
  echo -e "\e[1;33mPlease Pull New Requert Next\e[0m"
  echo -e "\033[37;36;4mhttps://github.com/$Uname/TranslateProject/pull/new/master\
\033[39;49;0m\n"
  read && clear
  echo -e "\e[1;33mThanks @"$Uname" https://linux.cn/\e[0m\n"
  }
  fi