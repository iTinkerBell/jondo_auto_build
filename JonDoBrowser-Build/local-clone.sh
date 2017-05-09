#!/bin/bash
#clone repositories to work with
cd $project_dir
cd ..
if ! [ -d 'local-repo' ]; then
	echo 'Creating local-repo directory.'
	mkdir 'local-repo'
fi
echo '- Using local-repo directory to clone remote repositories'
cd local-repo
git_dir=`pwd`

#clone tor-browser
source "$project_dir/local-clone-separate.sh" tor-browser https://git.torproject.org/tor-browser.git firefox-local

#clone jondo addon
source "$project_dir/local-clone-separate.sh" jondobrowser https://github.com/jondos/jondobrowser jondoaddon-local

#clone tbb-windows-installer
source "$project_dir/local-clone-separate.sh" tbb-windows-installer https://github.com/moba/tbb-windows-installer.git tbb-windows-installer-local

#clone tor-browser-build
cd ..
source "$project_dir/local-clone-separate.sh" tor-browser-build https://git.torproject.org/builders/tor-browser-build.git
cd tor-browser-build
git checkout $tor_browser_build_commit_hash
cd ..

#clone torupdates
cd /var
if ! [ -d 'www' ]; then
	mkdir 'www'
fi
cd www
source "$project_dir/local-clone-separate.sh" torupdates https://github.com/lancerajee/torupdates
