#!/bin/bash
#modify torbutton addon local repo
cd $project_dir
cd ../local-repo/torbutton-local

#make a new temporary branch from the tag
git checkout -b "jondo$tmp_branch_name" $torbutton_version

git grep -l 'About Torbutton' | xargs sed -i 's/About Torbutton/About JonDo addon/g'
git grep -l 'About Tor Browser' | xargs sed -i 's/About Tor Browser/About JonDoBrowser/g'
git grep -l 'About Tor' | xargs sed -i 's/About Tor/About JonDoBrowser/g'
git grep -l 'TorBrowser' | xargs sed -i 's/TorBrowser/JonDoBrowser/g'
git grep -l 'Tor Browser' | xargs sed -i 's/Tor Browser/JonDoBrowser/g'
git grep -l 'Tor-Browser' | xargs sed -i 's/Tor-Browser/JonDoBrowser/g'
git grep -l 'Tor Project' | xargs sed -i 's/Tor Project/JonDos GmbH/g'
git grep -l 'Firefox and the Firefox logos are trademarks of the Mozilla Foundation.' | xargs sed -i 's/Firefox and the Firefox logos are trademarks of the Mozilla Foundation./JonDoBrowser and the JonDoBrowser logos are trademarks of JonDos GmbH, Germany./g'
#modify german version
git grep -l 'Tor-Projekt' | xargs sed -i 's/Tor-Projekt/JonDos GmbH/g'
#copy jondo-strings from jondofox addon
cp ../jondoaddon-local/src/chrome/locale/en/about* ./src/chrome/locale/en/
cp ../jondoaddon-local/src/chrome/locale/de/about* ./src/chrome/locale/de/
cp ../jondoaddon-local/src/chrome/locale/en/brand* ./src/chrome/locale/en/
cp ../jondoaddon-local/src/chrome/locale/de/brand* ./src/chrome/locale/de/
cp ../jondoaddon-local/src/chrome/skin/* ./src/chrome/skin/
#add necessary strings to aboutTor.dtd
echo "<!ENTITY aboutTor.torbrowser_user_manual.accesskey \"M\">" >> ./src/chrome/locale/en/aboutTor.dtd
echo "<!ENTITY aboutTor.torbrowser_user_manual.label \"JonDoBrowser User Manual\">" >> ./src/chrome/locale/en/aboutTor.dtd
echo "<!ENTITY aboutTor.helpInfo3.label \"Run a Tor Relay Node »\">" >> ./src/chrome/locale/en/aboutTor.dtd
echo "<!ENTITY aboutTor.helpInfo3.link \"https://www.torproject.org/docs/tor-doc-relay.html.en\">" >> ./src/chrome/locale/en/aboutTor.dtd
#german version
echo "<!ENTITY aboutTor.torbrowser_user_manual.accesskey \"M\">" >> ./src/chrome/locale/de/aboutTor.dtd
echo "<!ENTITY aboutTor.torbrowser_user_manual.label \"JonDoBrowser-Benutzerhandbuch\">" >> ./src/chrome/locale/de/aboutTor.dtd
echo "<!ENTITY aboutTor.helpInfo3.label \"Einen Tor-Relaisknoten betreiben »\">" >> ./src/chrome/locale/de/aboutTor.dtd
echo "<!ENTITY aboutTor.helpInfo3.link \"https://www.torproject.org/docs/tor-doc-relay.html.en\">" >> ./src/chrome/locale/de/aboutTor.dtd
#commit to local git repo
source "$project_dir/local-commit.sh" $torbutton_version