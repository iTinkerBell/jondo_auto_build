#!/bin/bash
#modify torupdates local repository
cd /var/www/torupdates
#modify config.yml
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"archive_url: "* ]]; then
		echo "    archive_url: https://jondobrowser.jondos.de/torbrowser/"
	elif [[ $line == *"gpg_keyring: "* ]]; then
		echo "    gpg_keyring: $project_dir/keyring/tinkerbel.gpg"
	elif [[ $line == *"bundles_url: "* ]]; then
		echo "    bundles_url: https://jondobrowser.jondos.de/torbrowser/"
	elif [[ $line == *"mars_url: "* ]]; then
		echo "    mars_url: https://jondobrowser.jondos.de/torbrowser/"
	elif [[ $line == *"alpha: "* ]]; then
		echo "    alpha: $torbrowser_version"
	elif [[ $line == *"release: "* ]]; then
		echo "    release: $torbrowser_version"
	elif [[ $line == *"nightly: "* ]]; then
		echo "    #nightly: $torbrowser_version"
	elif [[ $line == *"6.5n:"* ]]; then
		echo "    $torbrowser_version:"
	elif [[ $line == *"platformVersion: "* ]]; then
		echo "        platformVersion: $firefox_version"
	else
		echo "$line"	
	fi
done < "config.yml" > "config.yml.tmp"
mv config.yml.tmp config.yml