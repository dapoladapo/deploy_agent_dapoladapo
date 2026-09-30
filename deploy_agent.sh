#!/bin/bash

script_directory="/deploy_agent_dapoladapo"

templates_directory="$script_directory/templates"

#Function to print menu
menu() {

while true; do

	echo
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

pre-flight_checks() {

	echo
	echo "--------------------"
	echo
	if command -v python3; then
		echo "Python version ="
		python3 --version
		echo "Python3 is installed"
	else
		echo "Python3 is not installed"
		echo "Please install it"
		exit 1
	fi

	echo
	if command -v zip; then
		echo "Zip is installed"
	else
		echo "Zip is not installed"
		echo "Please install it"
		exit 1
	fi

	echo
	echo "--------------------"
	if [ -d "$templates_directory" ]; then
		echo
		echo "Template directory exists"
		
		if [ -f "$templates_directory/assets.csv" ]; then
			echo "Assets template exists"
		else
			echo "Assets template don't exist"
			exit 1
		fi
		if [ -f "$templates_directory/attendance_checker.py" ];  then
			echo "Attendance checker template exists"
		else
			echo "Attendance checker template does not exist"
			exit 1
		fi
		if [ -f "$templates_directory/config.json" ]; then
			echo "Configuration file template exists"
		else
			echo "Configuration file template does not exist"
			exit 1
		fi
	else
		echo
		echo "Template directory does not exist"
	fi

	echo
	echo "pre-flight checks complete"


}

ask_project_name() {
read -r -p "What is the name of the project" project_name
}

pre-flight_checks
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
