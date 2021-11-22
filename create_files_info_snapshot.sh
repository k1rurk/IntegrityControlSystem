#!/bin/bash

. ./lib.sh
. ./cronlib.sh

declare -A arr
scanConfig arr
function makeGitDir(){
    if [ ! -d $absoluteGitDir ]
        then
                    echo "New gitDir created"
                    mkdir $absoluteGitDir && touch $initialSave $currentSave 
        fi

}
for scanDir in "${!arr[@]}"; do
				IFS=';' read -r -a arrayValues <<<"${arr[$scanDir]}"
				absoluteGitDir=${arrayValues[0]}
				initialSave=${arrayValues[1]}
				currentSave=${arrayValues[2]}
				timeScan=${arrayValues[3]}
				makeGitDir
				> $initialSave
				scanFiles $scanDir $initialSave
				cat $initialSave > $currentSave
				addToCron $scanDir $timeScan
done

