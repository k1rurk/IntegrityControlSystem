function addToCron(){
				directory=$1
				executable_script=$(pwd)"/integrity_control.sh"
				crontab_new="temP.txt"
				time=$2
				touch "$crontab_new"
				crontab -l > "$crontab_new"
				crontabCommand=$(echo "$directory" | sed 's|\.|\\.|g' | sed 's|\/|\\/|g')
				sed -i "/$crontabCommand/d" "$crontab_new"
				echo "$time \"$executable_script\" \"$directory\"" >> "$crontab_new"
				crontab "$crontab_new"
				rm "$crontab_new"
}
