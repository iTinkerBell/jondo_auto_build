#!/bin/bash
#Usage:
#./local-clone [repo_dir] [git repo url] [final_dir]
repo_dir=$1
repo_url=$2
final_dir="${3:-$1}"
if [ -e "$final_dir/.git" ]; then
	cd $final_dir
	echo "Updating with the remote repository $repo_url"
	git fetch --all
	git reset --hard FETCH_HEAD
	git clean -df
	cd ..
else
	git clone $repo_url
	if [ $repo_dir != $final_dir ]; then
		mv $repo_dir $final_dir
	fi
fi