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
		echo "Section \"Install Java SE Runtime Environment\" INSTALLJAVA"
		echo "  ; check 32-bit JRE"
		echo "  SetRegView 32"
		echo "  StrCpy \$1 \"SOFTWARE\\Wow6432Node\\JavaSoft\\Java Runtime Environment\""
		echo "  StrCpy \$2 0"
		echo "  ReadRegStr \$2 HKLM \"\$1\" \"CurrentVersion\""
		echo "  StrCmp \$2 \"\" DetectJRE64"
		echo "  ReadRegStr \$5 HKLM \"\$1\\\$2\" \"JavaHome\""
		echo "  StrCmp \$5 \"\" DetectJRE64"
		echo "  Goto done"

		echo "  ; check 64-bit JRE"
		echo "  DetectJRE64:"
		echo "  SetRegView 64"
		echo "  StrCpy \$1 \"SOFTWARE\\JavaSoft\\Java Runtime Environment\""
		echo "  StrCpy \$2 0"
		echo "  ReadRegStr \$2 HKLM \"\$1\" \"CurrentVersion\""
		echo "  StrCmp \$2 \"\" DetectJDK32"
		echo "  ReadRegStr \$5 HKLM \"\$1\\\$2\" \"JavaHome\""
		echo "  StrCmp \$5 \"\" DetectJDK32"
		echo "  Goto done"

		echo "  DetectJDK32:"
		echo "  SetRegView 32"
		echo "  ReadRegStr \$2 HKLM \"SOFTWARE\\Wow6432Node\\JavaSoft\\Java Development Kit\" \"CurrentVersion\""
		echo "  StrCmp \$2 \"\" DetectJDK64"
		echo "  ReadRegStr \$5 HKLM \"SOFTWARE\\Wow6432Node\\JavaSoft\\Java Development Kit\\\$2\" \"JavaHome\""
		echo "  StrCmp \$5 \"\" DetectJDK64"
		echo "  Goto done"

		echo "  DetectJDK64:"
		echo "  SetRegView 64"
		echo "  ReadRegStr \$2 HKLM \"SOFTWARE\\JavaSoft\\Java Development Kit\" \"CurrentVersion\""
		echo "  StrCmp \$2 \"\" NoJava"
		echo "  ReadRegStr \$5 HKLM \"SOFTWARE\\JavaSoft\\Java Development Kit\\\$2\" \"JavaHome\""
		echo "  StrCmp \$5 \"\" NoJava"
		echo "  Goto done"

		echo "  NoJava:"
		echo "    MessageBox MB_OK \"Install Java SE Runtime Environment\""
		echo "    File \"\${TBBSOURCE}\\Browser\\JonDo\\jre.exe\""
		echo "    ExecWait \"\$INSTDIR\\Browser\\JonDo\\jre.exe\""
		echo "  done:"

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