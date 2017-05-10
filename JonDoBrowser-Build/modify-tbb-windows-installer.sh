#!/bin/bash
#modify tbb-windows-installer addon local repo
cd $project_dir
cd ../local-repo/tbb-windows-installer-local
git checkout -b "jondo$tmp_branch_name" "v$tbb_windows_installer_version"
git grep -l 'torbrowser.ico' | xargs sed -i 's/torbrowser.ico/jondobrowser.ico/g'
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
rm torbrowser.ico
cp "$project_dir/img/firefox.ico" ./jondobrowser.ico
#commit to local git repo
source "$project_dir/local-commit.sh" "v$tbb_windows_installer_version"