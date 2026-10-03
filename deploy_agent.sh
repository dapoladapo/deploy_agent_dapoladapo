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
		exit 1
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
	echo "--------------------"

}
project_name=""
project_directory=""

ask_project_name() {
while true; do
	#If read doesn't work then close input field
	if ! read -r -p "What is the name of the project: " project_name_input; then
		echo
		echo "User input failed. Proceeding to exit"
		exit 1
	fi

	#Checking for any invalid symbols or is empty
	if [[ "$project_name_input" != *[\!\@\#\$\%\^\&\*\(\)\-\_\=\+\~\`\,\.\?\;\:\"\']* ]]; then
		project_name="$project_name_input"
		project_directory="$script_directory/attendance_tracker_$project_name_input"
		echo
		echo "Confirmed project name"
		return 0
	elif [ -z "$project_name_input" ]; then
		echo
		echo "Input is empty"
		return 0
	else
		echo
		echo "Invalid symbols. Pleasae use only numbers and letters"
	fi
done
}

check_if_directory_exists() {
if [ -d "$project_directory" ]; then
	echo
	echo "Project Directory already exists"

	if ! read -r -p "Do you want to overwrite it?(y/n): " user_overwrite_input; then
		echo
		echo "User input failed. Proceeding to exit."
	fi

	#if user consents then delete the folder and next function recreates it
	case "$user_overwrite_input" in
		y|Y)
			if [ "$project_directory" = "/" ]; then
				echo
				echo "Dangerous command. Aborting."
				exit 1
			elif [ "$project_directory" = "" ]; then
				echo
				echo "Nothing to overwrite. Aborting."
				exit 1
			else
				rm -rf "$project_directory"
			fi
			
			#Confirming if directory was deleted
			if [ -d "$project_directory" ]; then
				echo
				echo "Overwriting failed"
				return 1
			else
				echo
				echo "Deletion complete"
			fi
		;;
		n|N)
			echo
			echo "Procedure aborted. Project will be left as is."
			return 1
		;;
		*)
                        echo
                        echo "Invalid input. Procedure aborted."
                        return 1
                ;;
	esac
else
	echo
	echo "Project directory doesn't exist. Proceeding to create it."
fi
}

create_directory() {
	echo
	if ! mkdir "$project_directory"; then
		echo "Operation failed. Could not create '$project_directory'"
	else
		echo "Operation succeeded. Created '$project_directory'"
	fi

}

pre-flight_checks
ask_project_name
check_if_directory_exists
create_directory
echo "--------------------"
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
