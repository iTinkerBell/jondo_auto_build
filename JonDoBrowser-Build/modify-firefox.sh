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
#modification for update url and default socks proxy configuration
sed -i -- 's#aus1.torproject.org/torbrowser/update_3#jondobrowser.jondos.de#g' ./browser/app/profile/firefox.js
sed -i -- 's#www.torproject.org/download/download-easy.html#jondobrowser.jondos.de/jondobrowser/#g' ./browser/branding/official/pref/firefox-branding.js
sed -i -- 's#www.torproject.org/projects/torbrowser.html#jondobrowser.jondos.de/jondobrowser/#g' ./browser/branding/official/pref/firefox-branding.js
sed -i -- 's#pref("network.proxy.socks", "127.0.0.1");#pref("network.proxy.socks", "");#g' ./browser/app/profile/000-tor-browser.js
sed -i -- 's#pref("network.proxy.socks_port", 9150);#pref("network.proxy.socks_port", 0);#g' ./browser/app/profile/000-tor-browser.js
sed -i -- 's#pref("network.proxy.socks_remote_dns", true);#pref("network.proxy.socks_remote_dns", false);#g' ./browser/app/profile/000-tor-browser.js
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"app.update.url"* ]] && [[ $line == *"torproject.org"* ]]; then
		echo "pref(\"app.update.url\", \"https://jondobrowser.jondos.de/%CHANNEL%/%BUILD_TARGET%/%VERSION%/%LOCALE%\");"
	else
		echo "$line"	
	fi
done < "./browser/app/profile/firefox.js" > "./firefox.js_tmp"
mv ./firefox.js_tmp ./browser/app/profile/firefox.js
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
git grep -l 'addon.id == "torbutton@torproject.org" ||' | xargs sed -i 's/addon.id == "torbutton@torproject.org" ||/addon.id == "torbutton@torproject.org" || addon.id == "info@jondos.de" || addon.id == "jondo-launcher@jondos.de" || addon.id == "jondoswitcher@jondos.de" ||/g'
git grep -l 'addon.id != "torbutton@torproject.org" &&' | xargs sed -i 's/addon.id != "torbutton@torproject.org" &&/addon.id != "torbutton@torproject.org" && addon.id != "info@jondos.de" && addon.id != "jondo-launcher@jondos.de" && addon.id != "jondoswitcher@jondos.de" &&/g'
git grep -l 'aAddon.id == "torbutton@torproject.org" ||' | xargs sed -i 's/aAddon.id == "torbutton@torproject.org" ||/aAddon.id == "torbutton@torproject.org" || aAddon.id == "info@jondos.de" || aAddon.id == "jondo-launcher@jondos.de" || aAddon.id == "jondoswitcher@jondos.de" ||/g'
checkTorNetworkFound=0
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"bool isTor = false;"* ]]; then
		checkTorNetworkFound=1
	fi
	if [ $checkTorNetworkFound == 1 ]; then
		echo "$line"
	else
		if [[ $line == *"profile.default/extensions/torbutton@torproject.org.xpi"* ]]; then
			echo "bool isTor = false;"
			echo "#ifdef XP_WIN"
			echo "    WCHAR envValue[10];"
			echo "    int envValueLength = GetEnvironmentVariableW(L\"JONDO_NETWORK\", envValue, 10);"
			echo " 	  if (envValueLength > 0 && lstrcmpW(envValue, L\"tor\") == 0) isTor = true;"
			echo "#else"
			echo "	  const char *envValue = PR_GetEnv(\"JONDO_NETWORK\");"
			echo "	  if(envValue != NULL && strcmp(envValue, \"tor\") == 0) isTor = true;"
			echo "#endif"
		  	echo "if(isTor)	{"
		  	echo "    uriString.Append(\"profile.default/extensions/torbutton@torproject.org.xpi\");"
		  	echo "} else {"
		  	echo "    uriString.Append(\"profile.default/extensions/info@jondos.de.xpi\");"
		  	echo "}"
		elif [[ $line == *"extensions/torbutton@torproject.org.xpi"* ]]; then
			echo "bool isTor = false;"
			echo "#ifdef XP_WIN"
			echo "    WCHAR envValue[10];"
			echo "    int envValueLength = GetEnvironmentVariableW(L\"JONDO_NETWORK\", envValue, 10);"
			echo " 	  if (envValueLength > 0 && lstrcmpW(envValue, L\"tor\") == 0) isTor = true;"
			echo "#else"
			echo "	  const char *envValue = PR_GetEnv(\"JONDO_NETWORK\");"
			echo "	  if(envValue != NULL && strcmp(envValue, \"tor\") == 0) isTor = true;"
			echo "#endif"
		  	echo "if(isTor)	{"
		  	echo "    uriString.Append(\"extensions/torbutton@torproject.org.xpi\");"
		  	echo "} else {"
		  	echo "    uriString.Append(\"extensions/info@jondos.de.xpi\");"
		  	echo "}"
		else
			echo "$line"
		fi
	fi
done < "./toolkit/xre/nsAppRunner.cpp" > "./nsAppRunner.cpp.tmp"
mv ./nsAppRunner.cpp.tmp ./toolkit/xre/nsAppRunner.cpp

#enable jondofox addons instead of tor addons
git grep -l 'torbutton%40torproject.org' | xargs sed -i 's/torbutton%40torproject.org/info%40jondos.de/g'
git grep -l 'tor-launcher%40torproject.org' | xargs sed -i 's/tor-launcher%40torproject.org/jondoswitcher%40jondos.de:0.1.1,jondo-launcher%40jondos.de/g'
#modificaction for brand
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
git grep -l 'Tor Project' | xargs sed -i 's/Tor Project/JonDos GmbH/g'
git grep -l 'Firefox and the Firefox logos are trademarks of the Mozilla Foundation.' | xargs sed -i 's/Firefox and the Firefox logos are trademarks of the Mozilla Foundation./JonDoBrowser and the JonDoBrowser logos are trademarks of JonDos GmbH, Germany./g'
cp $project_dir/img/* ./browser/branding/official

#commit to local repo
source "$project_dir/local-commit.sh" $torbrowser_tag