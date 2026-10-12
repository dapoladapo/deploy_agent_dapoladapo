#!/bin/bash

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

templates_directory="$script_directory/templates"

project_name=""

project_directory=""

selected_project_directory=""

project_directories_created=0

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
		return 1
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

}

#Function nto handle signal interrupts
signal_handling() {

trap "" SIGINT SIGTSTP

echo
echo "Deploment was interrupted by a signal"

project_zip_name="attendance_tracker_${project_name}_archive.zip"

#Checking if there is a directory created, project name and whether its directory exists
if [[ "$project_directories_created" -eq 1 ]] && [[ -n "$project_name" ]] && [[ -d "$project_directory" ]]; then
	rm -f "$script_directory/$project_zip_name"
	
	if zip -rq "$script_directory/$project_zip_name" "$project_directory"; then
		echo "The incomplete project has been safely archived to: $script_directory/$project_zip_name"

		if rm -rf "project_directory"; then
			echo "The incomplete project has been removed."
		else
			echo "Incomplete project failed to be removed."
		fi
	else
		echo "Incomplete project has failed to archive. Keeping the project directory"
	fi
else
	echo "No project was created. Proceeding to exit."
fi

echo "Exiting..."
exit 0
}


#Function to deploy application
deploy_application() {

#signal capturing
trap 'signal_handling SIGINT' SIGINT
trap 'signal_handling SIGTSTP' SIGTSTP

pre_flight_checks() {

	echo
	echo "--------------------"
	echo
	if command -v python3; then
		echo "Python version ="
		if ! python3 --version; then
			echo "python3 --version could not run"
		fi
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
			return 1
		fi
		if [ -f "$templates_directory/attendance_checker.py" ];  then
			echo "Attendance checker template exists"
		else
			echo "Attendance checker template does not exist"
			return 1
		fi
		if [ -f "$templates_directory/config.json" ]; then
			echo "Configuration file template exists"
		else
			echo "Configuration file template does not exist"
			return 1
		fi
	else
		echo
		echo "Template directory does not exist"
		return 1
	fi

	echo
	echo "pre-flight checks complete"
	echo "--------------------"

}

ask_project_name() {
echo
while true; do
	#If read doesn't work then close input field
	if ! read -r -p "What is the name of the project: " project_name_input; then
		echo
		echo "User input failed. Proceeding to exit"
		return 1
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
		return 1
	else
		echo
		echo "Invalid symbols. Pleasae use only numbers and letters"
	fi
done
echo "--------------------"
}

check_if_directory_exists() {
if [ -d "$project_directory" ]; then
	echo
	echo "Project Directory already exists"

	if ! read -r -p "Do you want to overwrite it?(y/n): " user_overwrite_input; then
		echo
		echo "User input failed. Proceeding to exit."
		return 1
	fi

	#if user consents then delete the folder and next function recreates it
	case "$user_overwrite_input" in
		y|Y)
			if [ "$project_directory" = "/" ]; then
				echo
				echo "Dangerous command. Aborting."
				return 1
			elif [ "$project_directory" = "" ]; then
				echo
				echo "Nothing to overwrite. Aborting."
				return 1
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
		return 1
	else
		project_directories_created=1
		echo "Operation succeeded. Created '$project_directory'"
	fi

}


populate_fixed_files() {

	echo
	echo "--------------------"

	if ! mkdir "$project_directory/Helpers"; then
		echo "Creating Helpers subdirectory failed"
		return 1
	fi

	if ! mkdir "$project_directory/reports"; then
		echo "Creating reports subdirectory failed"
		return 1
	fi

	if ! cp "$templates_directory/attendance_checker.py" "$project_directory"; then
		echo "Copying attendance_checker.py failed"
		return 1
	fi

	if ! cp "$templates_directory/config.json" "$project_directory/Helpers"; then
		echo "Copying config.json failed"
		return 1
	fi
	echo
	echo "Population of fixed files is successful"
}

assets_template="$templates_directory/assets.csv"

populate_roster() {
echo
echo "--------------------"
echo
echo "Pick an option for populating the assets.csv roster [a or b]"
echo "Option A: Copy the roster template"
echo "Option B: Generate a fresh roster"
echo

if ! read -r -p "Option: " option_for_roster; then
	echo "User input failed. Proceeding to exit"
	return 1
fi

csv_line_count=$(($(wc -l < "$assets_template") ))
if ! read -r -p "How many students are there? [Max=$csv_line_count]: " user_input_rows; then
        echo "User input failed. Proceeding to exit"
        return 1
fi

#Making sure the rows correlate
$((user_input_rows + 1))

#Cheking if user_input_row is a number and isn't 0
if ! [[ "$user_input_rows" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please type a number from 1 - $csv_line_count"
        return 1
fi
if [[ "$user_input_rows" -eq 0 ]]; then
	echo "Invalid input. Please type a number from 1 - $csv_line_count"
	return 1
fi
if [[ "$user_input_rows" -gt "$csv_line_count" ]]; then
        echo "Please type a number from 1 - $csv_line_count"
        return 1
fi

case "$option_for_roster" in
	A|a)
		echo "Option A selected"

		#copy the amount of rows from csv template to file
		if ! head -n $((user_input_rows + 1)) "$assets_template" > "$project_directory/Helpers/assets.csv"; then
			echo "Failed to copy roster template"
			return 1
		fi
		echo "Copying roster template complete"

	;;
	B|b)
		echo "option B selected"
		sample_emails=("alice@example.com" "bob@example.com" "charlie@example.com" "diana@example.com" "ethan@example.com" "fatima@example.com" "george@example.com" "hannah@example.com" "ibrahim@example.com" "jasmine@example.com")
		sample_names=("Alice Johnson" "Bob Smith" "Charlie Davis" "Diana Prince" "Ethan Cole" "Fatima Noor" "George Mensah" "Hannah Kim" "Ibrahim Osei" "Jasmine Lee")

		#Creating the header line
		if ! echo "Email,Names,Attendance Count,Absence Count" > "$project_directory/Helpers/assets.csv"; then
			echo "Could not write to assests.csv. PLease update permissions"
			return 1
		fi

		#Creating new lines according to user input using the array of students.
		for ((row = 0; row < user_input_rows; row++)); do
			echo "${sample_emails[row]},${sample_names[row]},0,0" >> "$project_directory/Helpers/assets.csv"
		done

		#Updating the total sessions in config file
		if ! sed -i -E 's/("total_sessions":[[:space:]]*)[0-9]+/\11/' "$project_directory/Helpers/config.json"; then
			echo "Failed to update live sessions"
			return 1
		fi

		echo "Generating a fresh complete. (Total sessions are set to 1)"
	;;
	*)
		echo "Invalid input. Please pick option A or B"
		return 1
	;;
esac
}


setting_permissions() {
echo
echo "--------------------"
echo
if ! chmod +x "$project_directory/attendance_checker.py"; then
	echo "Failed to update permissions for attendance_checker.py"
	return 1
fi

if ! chmod 600 "$project_directory/Helpers/config.json"; then
	echo "Failed to update permissions for config.json"
	return 1
fi

echo "Permissions updated"
echo "Attendance_checker.py is executable and config.json is read/write only"
ls -l "$project_directory/attendance_checker.py" "$project_directory/Helpers/config.json"

}

update_threshold() {
echo
echo "-------------------"
echo

#I commented this section out because the user may not have jq command installed and I am not sure if I am allowed to install it for the checker to work
#warning_threshold=$(jq '.threshold.warning' "$project_directory/Helpers/config.json")
#failure_threshold=$(jq '.threshold.failure' "$project_directory/Helpers/config.json")
#echo "Current threshold levels: "
#echo "Warning threshold: $warning_threshold"
#echo "Failure threshold: $failure_threshold"
#echo

if ! read -r -p "Would you like to update alert thresholds? (y/n)" user_input_confirmation; then
	echo "User input failed. Proceeding to exit"
	return 1
fi

case "$user_input_confirmation" in
	y|Y)
		while true; do
			if ! read -r -p "New value for warning threshold [0-100]: " new_warning_threshold; then
				echo "User input failed. Proceeding to exit"
				return 1
			fi

			#Checking if the user input is valid
			if ! [[ "$new_warning_threshold" =~ ^[0-9]+$ ]]; then
				echo "Please enter a number between 0-100"
				return 1
			elif [[ "$new_warning_threshold" -lt 0 || "$new_warning_threshold" -gt 100 ]]; then
				echo "Please enter a number beteen 0-100"
				return 1
			else
				break
			fi
		done

		while true; do
			if ! read -r -p "New value for failure threshold [0-100]: " new_failure_threshold; then
				echo "User input failed. Proceeding to exit"
				return 1
			fi

			#checking if the user input is valid
			if ! [[ "$new_failure_threshold" =~ ^[0-9]+$ ]]; then
                                echo "Please enter a number between 0-100"
                                return 1
                        elif [[ "$new_failure_threshold" -lt 0 || "$new_failure_threshold" -gt 100 ]]; then
                                echo "Please enter a number beteen 0-100"
                                return 1
			elif [[ "$new_failure_threshold" -ge "$new_warning_threshold" ]]; then 
				echo "Failure threshold should be lower than warning threshold"
				return 1
                        else
                                break
                        fi
		done

		#Updating config.json
		if ! sed -i -E "s/(\"warning\":[[:space:]]*)[0-9]+/\1$new_warning_threshold/" "$project_directory/Helpers/config.json"; then
			echo "Failed to update warning threshold. Reverting to default"
			return 1
		fi

		if ! sed -i -E "s/(\"failure\":[[:space:]]*)[0-9]+/\1$new_failure_threshold/" "$project_directory/Helpers/config.json"; then
                        echo "Failed to update failure threshold. Reverting to default"
                        return 1
                fi

		#Confirmation
		echo "Successfully updated thresholds to:"
		echo "Warning threshold: $new_warning_threshold"
		echo "Failure threshold: $new_failure_threshold"
		echo
	;;
	n|N)
		echo "Leaving the default thresholds."
		return 0
	;;
	*)
		echo "Invalid input. Please input 'y' or 'n' for confirmation"
		return 1
	;;
esac

}

calling_functions() {
#Calling each function and if it does not run, it should return with failure

pre_flight_checks || return 1
ask_project_name || return 1
check_if_directory_exists || return 1
create_directory || return 1
populate_fixed_files || return 1
populate_roster || return 1
setting_permissions || return 1
update_threshold || return 1

echo "--------------------"
echo "System deployment complete"
}

calling_functions


#removing the signal_handling once the deployment is over
if calling_functions; then
	trap - SIGINT SIGSTP
	echo "Verifying the deployment by running the project"
	run_application "$project_directory"
else
	trap - SIGINT SIGSTP
	echo "Deployment failed"
	return 1
fi
}



#Function to run application
run_application() {

#Shows existing projects so user picks
echo "Existing projects: "
existing_projects=$(find "$script_directory" -maxdepth 1 -type d -name 'attendance_tracker_*')
if [[ -n "$existing_projects" ]]; then
	echo "$existing_projects"
else
	echo "None were found"
	return 1
fi

#First select the one of the avaliable projects
if ! read -r -p "Select project name (without 'attendance_tracker_'): " user_selected_project; then
	echo "User input failed. Proceeding to exit"
	return 1
fi

#validating user input
if [[ ! "$user_selected_project" =~ ^[A-Za-z0-9_][A-Za-z0-9_]*$ ]]; then
	echo "Invalid input. Please use only  letters, numbers or an underscore"
	return 1
fi

selected_project_directory="$script_directory/attendance_tracker_$user_selected_project"

#Making sure the selected project exists and has necessary files
if [[ -z "$selected_project_directory" ]]; then
	echo "Project is empty"
	return 1
elif [[ ! -d "$selected_project_directory" ]]; then
	echo "Project not found"
	return 1
fi

if [[ ! -f "$selected_project_directory/attendance_checker.py" ]]; then
	echo "attendance_checker.py file not found. Proceeding to exit"
	return 1
elif [[ ! -d "$selected_project_directory/Helpers" ]]; then
	echo "Helpers directory not found. Proceeding to exit"
	return 1
fi

#If everything is set, i start the attendance tracker
echo
echo "Starting the attendance tracker"
echo "--------------------"

if ! cd "$selected_project_directory"; then
	echo "Could not change directories"
	return 1
fi

if ! python3 attendance_checker.py; then
	echo "Could not run python file"
	return 1
fi

echo "--------------------"
echo "Closing attendance tracker"
echo

}

#Function to archive log files
archive_log_files() {

#Check if reports directory exists
if [[ ! -d "$selected_project_directory/reports" ]]; then
        echo "There are no reports directory found in the selected projects directory. Make sure the project has been deployed"
        return 1
fi

#Keeping a timestamp so all files have the same timestamp
timestamp=$(date +%Y%m%d_%H%M%S)

#Starting the archiving of logs
echo
echo "Archiving logs"
echo "-------------------"

for log_file in attendance absent; do
        log_file_path="$selected_project_directory/reports/$log_file.log"
        project_archive_directory="$selected_project_directory/archives/$log_file"
        project_archive_file="$project_archive_directory/${log_file}_${timestamp}.log"

        #Check if the log file exists
        if [[ -f "$log_file_path" ]]; then
                if ! mkdir -p "$project_archive_directory"; then
                        echo "Failed to create a project archive folder"
                        return 1
                fi

                if ! mv "$log_file_path" "$project_archive_file"; then
                        echo "Failed to archive reports/$log_file.log"
                        return 1
                fi

                echo "Archived: $project_archive_file"
                archived_files=$((archived + 1))
        else
                echo "Nothing to archived"
        fi
done

echo "-------------------"

if [[ "$archived_files" -eq 0 ]]; then
        echo "There are no logs found. Please run the application first"
else
        echo "$archived_files log file(s) archived"
fi

}


#Section to call functions in order
menu
