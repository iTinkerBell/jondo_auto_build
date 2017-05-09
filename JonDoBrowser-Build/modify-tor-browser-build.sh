#!/bin/bash
#modify tor-browser-build local repository
cd $project_dir
cd ../tor-browser-build

#copy .gpg to project
cp $keyring_path ./keyring/tinkerbel.gpg

#modify firefox build
git grep -l 'TorBrowser.app' | xargs sed -i 's/TorBrowser.app/JonDoBrowser.app/g'

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
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"mv"*"input_files_by_name/tor-launcher"* ]]; then
		nothing=""
	elif [[ $line == *"mv"*"input_files_by_name/torbutton"* ]]; then
		echo "mv [% c('input_files_by_name/jondoaddon') %] "'$TBDIR/$EXTSPATH/info@jondos.de.xpi'
	else
		echo "$line"	
	fi
done < "./projects/tor-browser/build" > "./build.tmp"
mv ./build.tmp ./projects/tor-browser/build

#modify tor-browser config
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"- project: tor-launcher"* ]] || [[ $line == *"name: tor-launcher"* ]] ; then
		nothing=""
	elif [[ $line == *"- project: torbutton"* ]]; then
		echo "  - project: jondoaddon"
	elif [[ $line == *"name: torbutton"* ]]; then
		echo "    name: jondoaddon"
	else
		echo "$line"	
	fi
done < "./projects/tor-browser/config" > "./config.tmp"
mv ./config.tmp ./projects/tor-browser/config

#remove tor-launcher from project
rm -r ./projects/tor-launcher

#rename torbutton to jondoaddon and modify config
mv ./projects/torbutton ./projects/jondoaddon
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