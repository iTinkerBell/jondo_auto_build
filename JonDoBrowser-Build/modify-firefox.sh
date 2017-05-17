#!/bin/bash
#modify firefox local repo
#get firefox branchname and tagname
cd $project_dir
cd ../tor-browser-build
while read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"git_hash: "* ]]; then
		line=${line##*]-}
		line=${line%%\'}
		tmp_build=${line##*-}
		tmp_subversion=${line%%-build*}		
	fi
	if [[ $line == *"firefox_version: "* ]]; then
		firefox_version=${line##*firefox_version: }
	fi
	if [[ $line == *"torbrowser_branch: "* ]]; then
		tmp_branch=${line##*torbrowser_branch: }
		break
	fi
done < "./projects/firefox/config"
torbrowser_branch="tor-browser-$firefox_version-$tmp_branch-$tmp_subversion"
torbrowser_tag="$torbrowser_branch-$tmp_build"
cd ..
cd local-repo/firefox-local
#git checkout $torbrowser_branch
#make a new temporary branch from the tag
git checkout -b "jondo$tmp_branch_name" $torbrowser_tag
#modification for update url
sed -i -- 's#aus1.torproject.org/torbrowser/update_3#jondobrowser.jondos.de#g' ./browser/app/profile/firefox.js
sed -i -- 's#www.torproject.org/download/download-easy.html#jondobrowser.jondos.de/jondobrowser/#g' ./browser/branding/official/pref/firefox-branding.js
sed -i -- 's#www.torproject.org/projects/torbrowser.html#jondobrowser.jondos.de/jondobrowser/#g' ./browser/branding/official/pref/firefox-branding.js
#modification for mar signature check disable
VerifySignatureFound=0
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"ArchiveReader::VerifySignature()"* ]]; then
		VerifySignatureFound=1
	fi
	echo "$line"
	if [ $VerifySignatureFound == 1 ] && [[ $line == *"}"* ]]; then
		VerifySignatureFound=0
		echo "return OK;"
	fi
done < "./toolkit/mozapps/update/updater/archivereader.cpp" > "./archivereader_tmp.cpp"
mv ./archivereader_tmp.cpp ./toolkit/mozapps/update/updater/archivereader.cpp
#modification for killing java when updating
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"const int callbackIndex ="* ]]; then
		echo "#if defined(XP_WIN)"
		echo "  system(\"taskkill /F /T /IM JonDo.exe\");"
		echo "  system(\"wmic process where \\\"name like \'%java%\'\\\" delete\");"
		echo "#elif defined(XP_MACOSX)"
		echo "  system(\"pkill -f \'JAP.app\'\");"
		echo "#else"
		echo "  system(\"pkill -f \'java.*JAP.jar*\'\");"
		echo "#endif"
	fi
	echo "$line"
done < "./toolkit/mozapps/update/updater/updater.cpp" > "./updater.cpp.tmp"
mv ./updater.cpp.tmp ./toolkit/mozapps/update/updater/updater.cpp
#modification for xpi signature check disable
git grep -l 'torbutton@torproject.org' | xargs sed -i 's/torbutton@torproject.org/info@jondos.de/g'
git grep -l 'torbutton%40torproject.org' | xargs sed -i 's/torbutton%40torproject.org/info%40jondos.de/g'
git grep -l 'tor-launcher@torproject.org' | xargs sed -i 's/tor-launcher@torproject.org/jondo-launcher@jondos.de/g'
git grep -l 'tor-launcher%40torproject.org' | xargs sed -i 's/tor-launcher%40torproject.org/jondo-launcher%40jondos.de/g'
#modificaction for brand
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
git grep -l 'Tor Project' | xargs sed -i 's/Tor Project/JonDos GmbH/g'
git grep -l 'Firefox and the Firefox logos are trademarks of the Mozilla Foundation.' | xargs sed -i 's/Firefox and the Firefox logos are trademarks of the Mozilla Foundation./JonDoBrowser and the JonDoBrowser logos are trademarks of JonDos GmbH, Germany./g'
cp $project_dir/img/* ./browser/branding/official

#commit to local repo
source "$project_dir/local-commit.sh" $torbrowser_tag