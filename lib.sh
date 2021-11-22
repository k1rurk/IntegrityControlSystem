SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
configFILE="$SCRIPTPATH/integrity_system.conf"
gitDir=".like_git_folder"
logFile="$SCRIPTPATH/violations_reports.log"

function compareFiles(){

    filename1=$1
    filename2=$2
    isChanged=false
    while read line1
    do
		isNotFound=1

		IFS=';' read -r -a arr1 <<< "$line1"

		while read line2
		do
			IFS=';' read -r -a arr2 <<< "$line2"
			
			if [[ ${arr1[0]} == ${arr2[0]} ]]
			then
				isNotFound=0
				if [[ ${arr1[3]} != ${arr2[3]} ]]
				then
					echo `date +"%Y-%M-%d %T"`" Файл ${arr2[0]} был модифицирован" >> "$logFile"
					isChanged=true
				fi
			fi
		done < "$filename2"

		
		if [ $isNotFound -eq 1 ] 
		then
			echo `date +"%Y-%M-%d %T"`" Новый файл ${arr1[0]} добавлен" >> "$logFile"
			isChanged=true
		fi

                  
    done < "$filename1"
		if $isChanged
		then
			DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus notify-send 'Нарушение целостности файлов ' ' Найдено несовпадение в файловой системе '
		fi
}
function scanFiles(){

	find "$1" -type f | while read F; do
			if [[ $(dirname "$F") != $absoluteGitDir ]]
			then
				local pathFile=$F
				local infoFile=$(stat -c "%n;%s;%w;%y;%A" "$pathFile")
				local hashFile=$(md5sum "$pathFile")
				IFS=' ' read -r -a hasharr <<<"${hashFile}"
				local infoFile="${infoFile};${hasharr[0]}"
				echo $infoFile >> "$2"
			fi
	done

}
function makeArrayVariables(){
	local -n mainArr=$2
	IFS=';' read -r -a array <<<"$1"
	IFS='=' read -r -a firstArgument <<<"${array[0]}"
	local dir_to_scan=${firstArgument[1]}
	local absoluteGitDir="${dir_to_scan}/${gitDir}" 
	local initialSave="${absoluteGitDir}/${array[1]}"
	local currentSave="${absoluteGitDir}/${array[2]}"
	local timeScan=${array[3]}
	local str="$absoluteGitDir;$initialSave;$currentSave;$timeScan"
	mainArr[$dir_to_scan]=$str
}
function scanConfig () 
{
	local -n myarray=$1	
	IFS=$'\n'
	if [ -f "$configFILE" ]
	then
	while read line
	do
		if [[ "$line" != \#* ]] && [[ ! -z $line ]]
		then	
			makeArrayVariables ${line[*]} myarray 
		fi
	done < "$configFILE"
	fi
}










