#!/bin/bash
tor_browser_build_commit_hash=${1:-b9fc5fc4a562ea8c5d7fdb797fd3c1ea6f6b413e}
echo "Building with $tor_browser_build_commit_hash bundle."
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#check if keyring exists
source "$project_dir/check-gpg.sh"

#clean git_clone directory
cd ..
if [ -d "tor-browser-build/git_clones" ]; then
	rm -r tor-browser-build/git_clones/firefox
	rm -r tor-browser-build/git_clones/jondoaddon
	rm -r tor-browser-build/git_clones/tbb-windows-installer
fi

#clone tor-browser-build : need to be done before any other cloning
source "$project_dir/local-clone-separate.sh" tor-browser-build https://git.torproject.org/builders/tor-browser-build.git
cd tor-browser-build
git checkout $tor_browser_build_commit_hash -f

#clone repositories to work with : jondoaddon, firefox, tbb-windows-installer, torupdates
source "$project_dir/local-clone.sh"

tmp_branch_name=`date +%Y%m%d%H%M%S`

#modify local repositories
source "$project_dir/modify-jondoaddon.sh"
source "$project_dir/modify-firefox.sh"
source "$project_dir/modify-tor-browser-build.sh"
source "$project_dir/modify-torupdates.sh"
source "$project_dir/modify-tbb-windows-installer.sh"

#make
cd $project_dir
cd ../tor-browser-build
mkdir -p "alpha/unsigned/$torbrowser_version"
rm -r "alpha/unsigned/$torbrowser_version"
make alpha
cd "alpha/unsigned/$torbrowser_version"
rename 's/torbrowser/jondobrowser/g' *
rename 's/TorBrowser/JonDoBrowser/g' *
rename 's/tor-browser/jondobrowser/g' *
sed -i -- 's#tor-browser#jondobrowser#g' ./sha256sums-unsigned-build.txt
sed -i -- 's#torbrowser#jondobrowser#g' ./sha256sums-unsigned-build.txt
sed -i -- 's#TorBrowser#JonDoBrowser#g' ./sha256sums-unsigned-build.txt

#copy
cd /var/www/torupdates/htdocs
if ! [ -d jondobrowser ] ; then
	mkdir jondobrowser
fi
cd $project_dir
cd ..
cp -r "tor-browser-build/alpha/unsigned/$torbrowser_version" "/var/www/torupdates/htdocs/jondobrowser"
cd /var/www/torupdates
./update_responses