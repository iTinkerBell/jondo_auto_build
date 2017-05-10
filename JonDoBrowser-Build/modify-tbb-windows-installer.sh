#!/bin/bash
#modify tbb-windows-installer addon local repo
cd $project_dir
cd ../local-repo/tbb-windows-installer-local
git checkout master
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
#commit to local git repo
echo $tbb_windows_installer_version
source "$project_dir/local-commit.sh" $tbb_windows_installer_version