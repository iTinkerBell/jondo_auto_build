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
git checkout $torbrowser_branch
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
#modification for xpi signature check disable
git grep -l 'torbutton@torproject.org' | xargs sed -i 's/torbutton@torproject.org/info@jondos.de/g'
git grep -l 'torbutton%40torproject.org' | xargs sed -i 's/torbutton%40torproject.org/info%40jondos.de/g'
#modificaction for brand
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
git grep -l 'Tor Project' | xargs sed -i 's/Tor Project/JonDos GmbH/g'
git grep -l 'Firefox and the Firefox logos are trademarks of the Mozilla Foundation.' | xargs sed -i 's/Firefox and the Firefox logos are trademarks of the Mozilla Foundation./JonDoBrowser and the JonDoBrowser logos are trademarks of JonDos GmbH, Germany./g'
cp $project_dir/img/* ./browser/branding/official
#commit to local repo
source "$project_dir/local-commit.sh" $torbrowser_tag