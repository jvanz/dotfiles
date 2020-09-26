#!/bin/bash

URL=$1
HTML=`mktemp`
PATTERN=".*txz$"
MD5_PATTERN=".*md5$"

curl -XGET -o $HTML  $URL

echo `xmllint --html --xpath //a/@href $HTML`

for link in `xmllint --html --xpath //a/@href $HTML`
do
	link=`echo $link | awk -F'"' '$0=$2'`
	if [[ $link =~ $PATTERN ]] || [[ $link =~ $MD5_PATTERN ]]; then
		curl -XGET -o $link $URL/$link 
	fi
done

rm -f $HTML



