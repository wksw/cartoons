#!/bin/bash

ROOTDIR=$(cd $(dirname $0);pwd)
NAME=$1
FROM=$2

if [ "$FROM"x = ""x -o "$NAME"x = ""x ];then
	echo '
Useage:
	/bin/bash ./cartoon.sh <name> <from>
'
	exit
fi

rm -rf $ROOTDIR/$NAME

CHAPTERIMAGES='['

while true
do
    if [ "$FROM"x = ""x ];then
        break
    fi
	html=$(curl -s https://www.36mh.com/manhua/$NAME/${FROM}.html)
	chapterPath=$(echo $html |awk -F '<script>' '{print $3}'|awk -F '</script>' '{print $1}'  |awk -F ';' '{print $6}' |awk -F '=' '{print $2}' | sed s/[[:space:]]//g)
	chapterImages=$(echo $html |awk -F '<script>' '{print $3}'|awk -F '</script>' '{print $1}' |awk -F ';' '{print $5}' |awk -F '=' '{print $2}' | sed s/[[:space:]]//g)
	title=$(echo $html |awk -F '<script>' '{print $3}'|awk -F '</script>' '{print $1}' |awk -F 'pageTitle' '{print $2}'|awk -F ';' '{print $1}' |awk -F '=' '{print $2}')
	FROM=$(echo $html |awk -F '<script>' '{print $3}'|awk -F '</script>' '{print $1}' |awk -F 'nextChapterData' '{print $2}' |awk -F ',' '{print $1}' |awk -F ':' '{print $2}' | sed s/[[:space:]]//g)
	CHAPTERIMAGES="${CHAPTERIMAGES}{title:${title:-'""'},chapterpath:${chapterPath},chapterImages:${chapterImages}},"
	if [ "$FROM" = "null" ];then
		break;
	fi
done

CHAPTERIMAGES="${CHAPTERIMAGES}]"

if [ "$CHAPTERIMAGES" = "[]" ];then
    exit 0
fi
mkdir -p $ROOTDIR/$NAME
cat << EOF > $ROOTDIR/$NAME/index.html
<html>
<head>
<meta charset="UTF-8">

<style type="text/css">
body {
	text-align:cneter;
}
button {
	width: 100px;
	height: 50px;
}
</style>
</head>

<body>

<div id="content" style="text-align:center;">
</div>

<script >

var name="$NAME"
var thisPage = 0
var chapterImages = $CHAPTERIMAGES

function nextChapter() {
    thisPage++
    if (thisPage > chapterImages.length) {
        return
    }
    var html = show(thisPage)
    document.getElementById("content").innerHTML=html;
    window.scrollTo(0,0);
    var storage = localStorage.getItem("chapter") || "{}"
    var storage_json = JSON.parse(storage)
    storage_json.$NAME = thisPage
    localStorage.setItem("chapter", JSON.stringify(storage_json))
}

function prevChapter() {
    thisPage--
    if (thisPage == 0) {
        return
    }
    var html = show(thisPage)
    document.getElementById("content").innerHTML=html;
    window.scrollTo(0,0);
    var storage = localStorage.getItem("chapter") || "{}"
    var storage_json = JSON.parse(storage)
    storage_json.$NAME = thisPage
    localStorage.setItem("chapter", JSON.stringify(storage_json))
}


function show(index) {
    var html = '<button onclick="nextChapter()">next</button><button onclick="prevChapter()">preview</button><hr><h3>' + index + '(' + chapterImages.length + ')' + ' chapter ' +chapterImages[index].title+ '</h3>'
    for (var i=0; i<chapterImages[index].chapterImages.length;i++) {
        html += '<img src="' + 'https://img001.yayxcc.com/' + chapterImages[thisPage].chapterpath + chapterImages[thisPage].chapterImages[i] + '">'
    }
    html += '<hr><button onclick="nextChapter()">next</button><button onclick="prevChapter()">preview</button><h3>' + index + '(' + chapterImages.length + ')' + ' chapter ' +chapterImages[index].title+ '</h3>'
    return html    
}

var storage = localStorage.getItem("chapter") || "{}"
var thisPage = JSON.parse(storage).$NAME || 0
var html = show(thisPage)
document.getElementById("content").innerHTML=html;
</script> 

</body>

</html>

EOF
