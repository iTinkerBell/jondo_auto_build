#!/bin/bash
#check if keyring exists
gpg_done=0
while read output
do
	if [[ $output == "pub"*"/"* ]]; then
		gpg_done=1
		tmp_index=`expr index "$output" /`
		keyring_fingerprint=${output:$tmp_index:8}
	fi
	if [[ $output == *"/.gnupg/"*".gpg" ]]; then
		keyring_path=$output
	fi
done <<< "$(gpg --list-keys)"
if [ $gpg_done == 1 ]; then
	echo "- Using keyring file $keyring_path and fingerprint $keyring_fingerprint"
else
	echo "gpg not done"
	echo "No keyring exist. Please generate a keyring using gpg --gen-key and try again."
	exit
fi
