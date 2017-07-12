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
	elif [[ $line == *"VersionCompare"* ]]; then
		jre_section_found=1
		echo "$line"
	elif [[ $line == *"Function CreateShortcuts"* ]] && [ $jre_section_found == 0 ]; then
		echo 'Function VersionCompare'
		echo '  !define VersionCompare `!insertmacro VersionCompareCall`'
		 
		echo '  !macro VersionCompareCall _VER1 _VER2 _RESULT'
		echo '    Push `${_VER1}`'
		echo '    Push `${_VER2}`'
		echo '    Call VersionCompare'
		echo '    Pop ${_RESULT}'
		echo '  !macroend'
		 
		echo '  Exch $1'
		echo '  Exch'
		echo '  Exch $0'
		echo '  Exch'
		echo '  Push $2'
		echo '  Push $3'
		echo '  Push $4'
		echo '  Push $5'
		echo '  Push $6'
		echo '  Push $7'
		 
		echo '  begin:'
		echo '  StrCpy $2 -1'
		echo '  IntOp $2 $2 + 1'
		echo '  StrCpy $3 $0 1 $2'
		echo "  StrCmp \$3 '' +2"
		echo "  StrCmp \$3 '.' 0 -3"
		echo '  StrCpy $4 $0 $2'
		echo '  IntOp $2 $2 + 1'
		echo "  StrCpy \$0 \$0 '' \$2"
		 
		echo '  StrCpy $2 -1'
		echo '  IntOp $2 $2 + 1'
		echo '  StrCpy $3 $1 1 $2'
		echo "  StrCmp \$3 '' +2"
		echo "  StrCmp \$3 '.' 0 -3"
		echo '  StrCpy $5 $1 $2'
		echo '  IntOp $2 $2 + 1'
		echo "  StrCpy \$1 \$1 '' \$2"
		 
		echo "  StrCmp \$4\$5 '' equal"
		 
		echo '  StrCpy $6 -1'
		echo '  IntOp $6 $6 + 1'
		echo '  StrCpy $3 $4 1 $6'
		echo "  StrCmp \$3 '0' -2"
		echo "  StrCmp \$3 '' 0 +2"
		echo '  StrCpy $4 0'
		 
		echo '  StrCpy $7 -1'
		echo '  IntOp $7 $7 + 1'
		echo '  StrCpy $3 $5 1 $7'
		echo "  StrCmp \$3 '0' -2"
		echo "  StrCmp \$3 '' 0 +2"
		echo '  StrCpy $5 0'
		 
		echo '  StrCmp $4 0 0 +2'
		echo '  StrCmp $5 0 begin newer2'
		echo '  StrCmp $5 0 newer1'
		echo '  IntCmp $6 $7 0 newer1 newer2'
		 
		echo "  StrCpy \$4 '1\$4'"
		echo "  StrCpy \$5 '1\$5'"
		echo '  IntCmp $4 $5 begin newer2 newer1'
		 
		echo '  equal:'
		echo '  StrCpy $0 0'
		echo '  goto end'
		echo '  newer1:'
		echo '  StrCpy $0 1'
		echo '  goto end'
		echo '  newer2:'
		echo '  StrCpy $0 2'
		 
		echo '  end:'
		echo '  Pop $7'
		echo '  Pop $6'
		echo '  Pop $5'
		echo '  Pop $4'
		echo '  Pop $3'
		echo '  Pop $2'
		echo '  Pop $1'
		echo '  Exch $0'
		echo 'FunctionEnd'

		echo 'Section "Install Java SE Runtime Environment" INSTALLJAVA'
		echo '  Var /GLOBAL JRE_REG_DIR'
		echo '  Var /GLOBAL JRE_CUR_VERSION'
		echo '  Var /GLOBAL JRE_HOME_DIR'
		echo '  Var /GLOBAL JRE_CHK_VERSION'

		echo '  ; check 32-bit JRE'
		echo '  SetRegView 32'
		echo '  StrCpy $JRE_REG_DIR "SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment"'
		echo '  StrCpy $JRE_CUR_VERSION 0'
		echo '  ReadRegStr $JRE_CUR_VERSION HKLM "$JRE_REG_DIR" "CurrentVersion"'
		echo '  StrCmp $JRE_CUR_VERSION "" DetectJRE64'
		echo '  ReadRegStr $JRE_HOME_DIR HKLM "$JRE_REG_DIR\$JRE_CUR_VERSION" "JavaHome"'
		echo '  StrCmp $JRE_HOME_DIR "" DetectJRE64'
		echo '  Goto JREVersionCompare'

		echo '  ; check 64-bit JRE'
		echo '  DetectJRE64:'
		echo '  SetRegView 64'
		echo '  StrCpy $JRE_REG_DIR "SOFTWARE\JavaSoft\Java Runtime Environment"'
		echo '  StrCpy $JRE_CUR_VERSION 0'
		echo '  ReadRegStr $JRE_CUR_VERSION HKLM "$JRE_REG_DIR" "CurrentVersion"'
		echo '  StrCmp $JRE_CUR_VERSION "" DetectJDK32'
		echo '  ReadRegStr $JRE_HOME_DIR HKLM "$JRE_REG_DIR\$JRE_CUR_VERSION" "JavaHome"'
		echo '  StrCmp $JRE_HOME_DIR "" DetectJDK32'
		echo '  Goto JREVersionCompare'

		echo '  DetectJDK32:'
		echo '  SetRegView 32'
		echo '  ReadRegStr $JRE_CUR_VERSION HKLM "SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit" "CurrentVersion"'
		echo '  StrCmp $JRE_CUR_VERSION "" DetectJDK64'
		echo '  ReadRegStr $JRE_HOME_DIR HKLM "SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit\$JRE_CUR_VERSION" "JavaHome"'
		echo '  StrCmp $JRE_HOME_DIR "" DetectJDK64'
		echo '  Goto JREVersionCompare'

		echo '  DetectJDK64:'
		echo '  SetRegView 64'
		echo '  ReadRegStr $JRE_CUR_VERSION HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"'
		echo '  StrCmp $JRE_CUR_VERSION "" NoJava'
		echo '  ReadRegStr $JRE_HOME_DIR HKLM "SOFTWARE\JavaSoft\Java Development Kit\$JRE_CUR_VERSION" "JavaHome"'
		echo '  StrCmp $JRE_HOME_DIR "" NoJava'
		echo '  Goto JREVersionCompare'

		echo '  JREVersionCompare:'
		echo '    StrCpy $JRE_CHK_VERSION 0'
		echo '    ${VersionCompare} "1.8" "$JRE_CUR_VERSION" $JRE_CHK_VERSION'
		echo '    ${If} $JRE_CHK_VERSION == "1"'
		echo '      Goto NoJava'
		echo '    ${Else}'
		echo '      RETURN'
		echo '    ${EndIf}'

		echo '  NoJava:'
		echo '    MessageBox MB_OK|MB_ICONINFORMATION "Installer will now install Java SE Runtime Environment"'
		echo '    File "${TBBSOURCE}\Browser\JonDo\jre.exe"'
		echo '    ExecWait "$INSTDIR\Browser\JonDo\jre.exe"'
		echo '    RETURN'

		echo 'SectionEnd'
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