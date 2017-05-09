#!/bin/bash
tor_browser_build_commit_hash=${1:-b9fc5fc4a562ea8c5d7fdb797fd3c1ea6f6b413e}
echo $tor_browser_build_commit_hash
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#check if keyring exists
source "$project_dir/check-gpg.sh"

#clone repositories to work with
source "$project_dir/local-clone.sh"

#modify local repositories
source "$project_dir/modify-jondoaddon.sh"
source "$project_dir/modify-firefox.sh"
source "$project_dir/modify-tor-browser-build.sh"
source "$project_dir/modify-torupdates.sh"

#make
cd $project_dir
cd ../tor-browser-build
make alpha

#copy
cd /var/www/torupdates/htdocs
if ! [ -d torbrowser ] ; then
	mkdir torbrowser
fi
cd $project_dir
cd ..
cp -r "tor-browser-build/alpha/unsigned/$torbrowser_version" "/var/www/torupdates/htdocs/torbrowser"
cd ../../
./update_responses