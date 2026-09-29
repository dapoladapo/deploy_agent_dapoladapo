#!/bin/bash

script_directory=

templates_directory="$script_directory"

#Function to print menu
menu() {

while true; do
	
	echo "+_+_+_+_+_Main Menu_+_+_+_+_+"
	echo
	echo "1. Deploy Application"
	echo "2. Run Application"
	echo "3. Archive log files"
	echo "4. Quit"
	echo

	#If read doesn't work then clode but if it does then put users input in option variable
	if ! read -r -p "Pick an option between 1-4: " option; then
		echo
		echo "User input failed. Proceeding to exit"
		exit 0
	fi


	case "$option" in
		1)
			deploy_application
			;;
		2)
			run_application
			;;
		3)
			archive_log_files
			;;
		4)
			echo
			echo "----------Goodbye!----------"
			exit 0
			;;
		*)
			echo
			echo "Invalid input. Please pick an option between 1-4"
			;;
	esac
done

echo"Please pick option 1-4"


}




#Function to deploy application
deploy_application() {
echo "deploy ran"


}

#Function to run application
run_application() {
echo "run ran"


}

#Function to archive log files
archive_log_files() {
echo "Archive ran"

}


#Section to call functions in order
menu
