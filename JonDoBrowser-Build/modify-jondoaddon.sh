#!/bin/bash
#modify jondo addon local repo
cd $project_dir
cd ../local-repo/jondoaddon-local
cp $project_dir/makexpi.sh ./

#get version for jondoaddon
while read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"<em:version>"* ]]; then
		line=${line##*<em:version>}
		jondoaddon_version=${line%%</em:version>}
		break
	fi
done < "src/install.rdf"
git grep -l 'About Torbutton' | xargs sed -i 's/About Torbutton/About JonDo addon/g'
git grep -l 'About Tor Browser' | xargs sed -i 's/About Tor Browser/About JonDoBrowser/g'
git grep -l 'About Tor' | xargs sed -i 's/About Tor/About JonDoBrowser/g'
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
git grep -l 'Tor-Browser' | xargs sed -i 's/Tor-Browser/JonDoBrowser/g'
git grep -l 'Tor Project' | xargs sed -i 's/Tor Project/JonDos GmbH/g'
git grep -l 'Firefox and the Firefox logos are trademarks of the Mozilla Foundation.' | xargs sed -i 's/Firefox and the Firefox logos are trademarks of the Mozilla Foundation./JonDoBrowser and the JonDoBrowser logos are trademarks of JonDos GmbH, Germany./g'
#modify german version
#tor specific string change
git grep -l 'Tor-Projekt' | xargs sed -i 's/Tor-Projekt/JonDos GmbH/g'
#commit to local git repo
source "$project_dir/local-commit.sh" $jondoaddon_version