#!/bin/bash
#modify tor-browser-build local repository
cd $project_dir
cd ../tor-browser-build

#copy .gpg to project
cp $keyring_path ./keyring/tinkerbel.gpg

#modify firefox build
#git grep -l 'TorBrowser.app' | xargs sed -i 's/TorBrowser.app/JonDoBrowser.app/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
mv projects/tor-browser/Bundle-Data/mac/TorBrowser projects/tor-browser/Bundle-Data/mac/JonDoBrowser
mv projects/tor-browser/Bundle-Data/PTConfigs/mac/TorBrowser.app.meek-http-helper projects/tor-browser/Bundle-Data/PTConfigs/mac/JonDoBrowser.app.meek-http-helper

#modify tbb-windows-installer config
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"git_url: "* ]]; then
		echo "git_url: $git_dir/tbb-windows-installer-local/.git"
	elif [[ $line == *"gpg_keyring: "* ]]; then
		echo "gpg_keyring: tinkerbel.gpg"
	elif [[ $line == *"version: "* ]]; then
		tbb_windows_installer_version=${line##*version: }
		echo "$line"
	else
		echo "$line"	
	fi
done < "./projects/tbb-windows-installer/config" > "./config.tmp"
mv ./config.tmp ./projects/tbb-windows-installer/config

#modify firefox config
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"git_url: "* ]]; then
		echo "git_url: $git_dir/firefox-local/.git"
	elif [[ $line == *"gpg_keyring: "* ]]; then
		echo "gpg_keyring: tinkerbel.gpg"
	else
		echo "$line"	
	fi
done < "./projects/firefox/config" > "./config.tmp"
mv ./config.tmp ./projects/firefox/config

#modify tor-browser build
JonDoToTorFound = 0
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"mv"*"input_files_by_name/tor-launcher"* ]]; then
		#nothing=""
		echo "$line"
		echo "mv \$rootdir/JonDo/jondo-launcher@jondos.de.xpi \$TBDIR/\$EXTSPATH/jondo-launcher@jondos.de.xpi"
		echo "mv \$rootdir/JonDo/jondoswitcher@jondos.de.xpi \$TBDIR/\$EXTSPATH/jondoswitcher@jondos.de.xpi"
	elif [[ $line == *"input_files_by_name/tor"*"tor.tar.gz"* ]]; then
		#nothing=""
		echo "$line"
	elif [[ $line == *"Extract the MAR tools"* ]]; then
		#copy JonDo for windows
		echo "[% IF c(\"var/windows\") %]"
		echo "  mkdir -p \$TBDIR/JonDo"
		echo "  mv \$rootdir/JonDo/JonDo_Windows/* \$TBDIR/JonDo/"
		echo "[% END %]"
		echo ""
		echo "[% IF c(\"var/linux\") %]"
		echo "  mkdir -p \$TBDIR/JonDo"
		echo "  mv \$rootdir/JonDo/JonDo_Linux/* \$TBDIR/JonDo/"
		echo "[% END %]"
		echo ""
		echo "[% IF c(\"var/osx\") %]"
		echo "  mkdir -p \$TBDIR/Contents/MacOS/JonDo"
		echo "  mv \$rootdir/JonDo/JonDo_OSX/JonDoLauncher \$TBDIR/Contents/MacOS/JonDo/"
		echo "  tar -xvf \$rootdir/JonDo/JonDo_OSX/JAP.app.tar.gz -C \$TBDIR/"
		echo "[% END %]"
		echo ""
		echo "$line"
	elif [[ $line == *"mv"*"input_files_by_name/torbutton"* ]]; then
		echo "$line"
		echo "mv [% c('input_files_by_name/jondoaddon') %] "'$TBDIR/$EXTSPATH/info@jondos.de.xpi'
	elif [[ $line == *"TORBINPATH"* ]] || [[ $line == *"TORCONFIGPATH"* ]] || [[ $line == *"MEEKPROFILEPATH"* ]]; then
		#nothing=""
		echo "$line"
	elif [[ $line == *"mkdir"*"/Tor" ]] || [[ $line == *"cp"*"/Tor/" ]] || [[ $line == *"chomod"*"/Tor" ]]; then
		#nothing=""
		echo "$line"
	elif [[ $line == *"zip -Xm omni.ja update.locale"* ]]; then
		JonDoToTorFound = 1
		echo "$line"
	elif [[ $line == *"MYDIR1"* ]]; then
		JonDoToTorFound = 2
		echo "$line"
	elif [ $JonDoToTorFound == 1 ] && [[ $line == *"var/windows"* ]]; then
		JonDoToTorFound = 3
		echo "MYDIR1=\$TBDIR/JonDo"
		echo "MYDIR2=\$TBDIR/\$EXTSPATH"
		echo "[% IF c(\"var/osx\") %]"
		echo "  MYDIR1=\$TBDIR/Contents/MacOS/JonDo"
		echo "[% ELSE %]"
		echo "  cp -r \$TBDIR/JonDoBrowser \$TBDIR/TorBrowser"
		echo "[% END %]"
		echo "cp \$MYDIR2/info@jondos.de.xpi \$MYDIR1/info@jondos.de.xpi"
		echo "mv \$MYDIR2/torbutton@torproject.org.xpi \$MYDIR1/torbutton@torproject.org.xpi"
		echo "mv \$MYDIR2/tor-launcher@torproject.org.xpi \$MYDIR1/tor-launcher@torproject.org.xpi"
		echo "$line"
	else
		echo "$line"	
	fi
done < "./projects/tor-browser/build" > "./build.tmp"
mv ./build.tmp ./projects/tor-browser/build
sed -i -- 's#tor-browser_#jondobrowser_#g' ./projects/tor-browser/build
sed -i -- 's#PKG_DIR="tor-browser"#PKG_DIR="jondobrowser"#g' ./projects/tor-browser/build
sed -i -- 's#OUTDIR/tor-browser#OUTDIR/jondobrowser#g' ./projects/tor-browser/build
sed -i -- 's#OUTDIR/torbrowser-install#OUTDIR/jondobrowser-install#g' ./projects/tor-browser/build
sed -i -- 's#MAR_FILE=tor-browser#MAR_FILE=jondobrowser#g' ./projects/tor-browser/build

#modify tor-browser config
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"- project: tor-launcher"* ]] || [[ $line == *"name: tor-launcher"* ]] ; then
		#nothing=""
		echo "$line"
	elif [[ $line == *"- project: torbutton"* ]]; then
		echo "  - project: jondoaddon"
		echo "    name: jondoaddon"
		echo "$line"
	elif [[ $line == *"- project: tor" ]] || [[ $line == *"name: tor" ]] ; then
		#nothing=""
		echo "$line"
	elif [[ $line == *"filename: Bundle-Data"* ]]; then
		echo "$line"
		echo "  - filename: JonDo"
	else
		echo "$line"	
	fi
done < "./projects/tor-browser/config" > "./config.tmp"
mv ./config.tmp ./projects/tor-browser/config
cp -r "$project_dir/JonDo" ./projects/tor-browser/JonDo
cd projects/tor-browser/JonDo/JonDo_OSX
if [ -d JAP.app ]; then
	tar -cvzf JAP.app.tar.gz ./JAP.app
	rm -r JAP.app
fi
cd ../../../../

#remove tor, tor-launcher from project
#rm -r ./projects/tor-launcher

#rename torbutton to jondoaddon and modify config
#mv ./projects/torbutton ./projects/jondoaddon
cp -r ./projects/torbutton ./projects/jondoaddon
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"git_url: "* ]]; then
		echo "git_url: $git_dir/jondoaddon-local/.git"
	elif [[ $line == *"gpg_keyring: "* ]]; then
		echo "gpg_keyring: tinkerbel.gpg"
	elif [[ $line == "version: "* ]]; then
		echo "version: $jondoaddon_version"
	else
		echo "$line"	
	fi
done < "./projects/jondoaddon/config" > "./config.tmp"
mv ./config.tmp ./projects/jondoaddon/config

#get browser main version number
while read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"torbrowser_version: "* ]]; then
		line=${line##*: \'}
		torbrowser_version=${line%%\'}
		break
	fi
done < "rbm.conf"
#remove other locales except for German and English
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"- ar" ]] || [[ $line == *"- es-ES" ]] || [[ $line == *"- fa" ]] || [[ $line == *"- fr" ]] || [[ $line == *"- it" ]] || [[ $line == *"- ko" ]] || [[ $line == *"- nl" ]] || [[ $line == *"- pl" ]] || [[ $line == *"- pt-BR" ]] || [[ $line == *"- ru" ]] || [[ $line == *"- tr" ]] || [[ $line == *"- vi" ]] || [[ $line == *"- zh-CN" ]] || [[ $line == *"var/locale_ja"* ]]; then
		nothing = ""
	else
		echo "$line"	
	fi
done < "rbm.conf" > "rbm.conf.tmp"
mv rbm.conf.tmp rbm.conf