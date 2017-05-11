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
#modify nsi script to include jre installer
#modify tor-browser build
jre_section_found=0
while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"RequestExecutionLevel"* ]]; then
		echo "  RequestExecutionLevel admin"
	elif [[ $line == *"Install Java SE Runtime Environment"* ]]; then
		jre_section_found=1
		echo "$line"
	elif [[ $line == *"Function CreateShortcuts"* ]] && [ $jre_section_found == 0 ]; then
		echo "Section \"Install Java SE Runtime Environment\""
		echo "  MessageBox MB_OK \"Install Java SE Runtime Environment?\""
		echo "  File \"\${TBBSOURCE}\\Browser\\JonDo\\jre.exe\""
		echo "  ExecWait \"\$INSTDIR\\Browser\\JonDo\\jre.exe\""
		echo "SectionEnd"
		echo ""
		echo "$line"
	else
		echo "$line"	
	fi
done < "torbrowser.nsi" > "torbrowser.nsi.tmp"
rm torbrowser.nsi
mv torbrowser.nsi.tmp torbrowser.nsi
#commit to local git repo
source "$project_dir/local-commit.sh" "v$tbb_windows_installer_version"