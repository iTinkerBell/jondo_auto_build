#!/bin/bash
tagname=$1
#commit to local repository
git add *
git commit -m "automatic commit for jondobrowser-local"
#get the last commit hash
while read output
do
	if [[ $output == "commit "* ]]; then
		commit_hash=${output:7}
	fi
done <<< "$(git log -1)"
#give a tagname
git tag -a $tagname $commit_hash -m "automatic commit for jondobrowser-local" -f
#config to use fingerprint
git config --local user.signingkey $keyring_fingerprint
#sign the commit
echo $tagname, $keyring_fingerprint
git tag -s $tagname -m "automatic signing" -f