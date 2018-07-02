#!/bin/bash

ROOTDIR=$(cd $(dirname $0);pwd)
PROCESS=${1:-100}

trap "exec 3>&-;exec 3<&-;exit 0" 2
[ -e ./$$ ] || mkfifo ./$$
exec 3<> ./$$
rm -rf ./$$
for i in $(seq $PROCESS)
do
	echo >&3
done


html=$(curl -s https://www.36mh.com/list/lianzai/)
totalpage=$(echo  $html | sed -r 's/.*<li class="last"><a href=(.+)data-page.*/\1/'|awk -F '"' '{print $2}' |awk -F '/' '{print $4}')
echo "------------total $totalpage pages---------"


for i in $(seq 1 $totalpage)
do
	echo "============page $i=========="
	if [ $i -eq 1 ];then
		i=""
	fi
	html=$(curl -s https://www.36mh.com/list/lianzai/$i)
	pages=$(echo  $html |awk -F '<ul' '{print $16}' |awk -F '<img' '{for(i=1;i<NF;i++){print $i}}'| sed -r 's/.*href=(.+)title.*/\1/' |awk -F '"' '{print $2}')
	for p in $pages
	do
		read -u3
		{
			cartoon=$(curl -s $p)
			name=$(echo $p |awk -F '/' '{print $(NF-1)}')
			from=$(echo $cartoon | awk -F '<ul id="chapter-list-4"' '{print $2}'|awk -F '.html' '{print $1}'|awk -F '/' '{print $NF}')
			echo $name $from
			if [ "$name"x != ""x -a "$from"x != ""x ];then
				/bin/bash $ROOTDIR/cartoon.sh $name $from 
			fi
			echo >&3
		}&
	done
done
wait
echo 3>&-
echo 3<&-