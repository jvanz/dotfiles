#!/bin/bash

cd $REPOSITORY_PATH

git pull

HAS_CHANGES="$(git status --porcelain | wc -l)"
if [ "$HAS_CHANGES" -eq 0 ]; then
	exit 0
fi

git add .
git commit  -m "Repository sync: $(date --iso-8601=minutes)"
git push 

