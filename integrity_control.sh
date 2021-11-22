#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
FILE="$SCRIPTPATH/lib.sh" && test -f "$FILE" && source "$FILE"
declare -A arr
if [ $# -eq 0 ]
then
				scanConfig arr

				for scanDir in "${!arr[@]}"; do
								IFS=';' read -r -a arrayValues <<<"${arr[$scanDir]}"
								absoluteGitDir=${arrayValues[0]}
								initialSave=${arrayValues[1]}
								currentSave=${arrayValues[2]}
								>"$currentSave"
								scanFiles $scanDir $currentSave
								compareFiles $currentSave $initialSave
				done
else
				dir=$1
				stringFromConfig=$(grep "$dir" "$configFILE")
				IFS=';' read -r -a array <<<"$stringFromConfig"
				absoluteGitDir="${dir}/${gitDir}" 
				initialSave="${absoluteGitDir}/${array[1]}"
				currentSave="${absoluteGitDir}/${array[2]}"
				>"$currentSave"
				scanFiles "${dir}" "$currentSave"
				compareFiles "$currentSave" "$initialSave"
fi
