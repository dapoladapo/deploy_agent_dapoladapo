#!/bin/bash

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

}




#Function to deploy application
deploy_application() {

pre_flight_checks() {

	echo
	echo "--------------------"
	echo
	if command -v python3; then
		echo "Python version ="
		if ! python3 --version; then
			"python3 --version could not run"
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
project_name=""
project_directory=""

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
	exit 1
fi

csv_line_count=$(($(wc -l < "$assets_template") +1 ))
if ! read -r -p "How many students do you want to copy? [Max=$csv_line_count]: " user_input_rows; then
        echo "User input failed. Proceeding to exit"
        return 1
fi

#Cheking if user_input_row is a number and isn't 0
if ! [[ "$user_input_rows" =~ ^[0-9]+$ || "$user_input_rows" -eq 0 ]]; then
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
			elif [[ "$new_failure_threshold" -gt "$new_warning_threshold" ]]; then 
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
