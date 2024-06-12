#!/bin/bash

branch_name=$(git branch --show-current)

echo $branch_name

if [ $branch_name = deploy ]; then
	echo "bulding the site with jekyll"
	bundle exec jekyll build
fi

