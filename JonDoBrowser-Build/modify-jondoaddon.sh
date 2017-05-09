#!/bin/bash
#modify jondo addon local repo
cd $project_dir
cd ../local-repo/jondoaddon-local
cp $project_dir/makexpi.sh ./
git mv jondoaddon src
#get version for jondoaddon
while read -r line || [[ -n "$line" ]]; do
	if [[ $line == *"<em:version>"* ]]; then
		line=${line##*<em:version>}
		jondoaddon_version=${line%%</em:version>}
		break
	fi
done < "src/install.rdf"
git grep -l 'About Torbutton' | xargs sed -i 's/About Torbutton/About JondDo addon/g'
git grep -l 'About Tor' | xargs sed -i 's/About Tor/About JondDoBrowser/g'
#commit to local git repo
source "$project_dir/local-commit.sh" $jondoaddon_version