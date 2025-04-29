#!/bin/bash

nix_clean() {
	if [[ -r "$1" ]]; then
		dos2unix $1 2> /dev/null
		sed -r '/^\s*$/d' $1 > .tmp
		cp .tmp $1
		rm -f .tmp
		echo "OK - Processed $1"
	else
		echo "Error - $1 unreadable".
	fi
}


if [[ "${1:0:1}" =~ "?" ]]; then
	echo "Usage: $0 [filename]"
	echo :
	echo "Description: Script will convert file to unix via dos2unix and remove all empty lines. If [filename] is not provided, script will scan for .txt file(s) and process them."
	exit 1
elif [[ -n "$1" ]]; then
	nix_clean $1
else
	for file in `ls *.txt`; do
		nix_clean ${file}
	done
fi


