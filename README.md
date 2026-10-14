# Deploy Agent Scripting



## Overview

This application is a script that if built with 3 features: to deploy, run and archive logs of a student attendance tracker. 

No. | Feature | Description
--- | --- | ---
1.  | Deploy  | This feature is built to check that all the requirements to run this system is set, builds out the system structure and sets up the ideal environment for the system to run. 
2.  | Run     | This feature will start the student attendance in a deployed project. 
3.  | Archive | This feature is will move all the active logs into an archived folder with timestamps. 



## Requirements to run the script

You would need 4 things

1. A computer system with Bash to run the script
2. Python3 needs to be installed
	- This is so it can run the `attendance_checker.py` file
3. Zip needs to be installed.
	- This is so achrived files can be zipped and saved safely. 
4. 'templates/' directory with necessary files
	- These files and directoyr is needed for the system to deploy successfully. 

Please make sure all of these are installed before moving on



## System Structure

Once you clone the repository, the file system will look like such

```bash
deploy_agent_dapoladapo/
├── deploy_agent.sh          
├── templates/               
│   ├── attendance_checker.py
│   ├── assets.csv           
│   └── config.json          
├── README.md
└── .gitignore               
```


Once you deploy, run and archive files in the system, the structure will look like this:

```bash
attendance_tracker_v1/
├── attendance_checker.py    
├── Helpers/
│   ├── assets.csv           
│   └── config.json          
├── reports/
└── archives/
    ├── attendance/
    │   └── attendance_YYYYMMDD_HHMMSS.log
    └── absent/
        └── absent_YYYYMMDD_HHMMSS.log                 
```

## Getting started

1. Clone the repository

```bash
git clone https://github.com/dapoladapo/deploy_agent_dapoladapo.git
cd deploy_agent_dapoladapo
```

2. Make sure the script is executable with this command

```bash
chomd +x deploy_agent.sh
```

3. Run the script

```bash
./deploy_agent.sh
```

## How to select a feature

The interactive menu is built as such 
```bash
+_+_+_+_+_Main Menu_+_+_+_+_+

1. Deploy Application
2. Run Application
3. Archive log files
4. Quit

Pick an option between 1-4:
``` 

Simply type a number for the corresponding feature
Input number | Corresponding action
----- | -----
`1` | Feature 1: Deploy new project
`2` | Feature 2: Run the project
`3` | Feature 3: Archive log files from the project
`4` | Quit the system


## Feature 1: Deploy a new projects

### Step 1: Pre-flight checks
- Verifies `python3` is installed
- Verifies `zip` is installed
- Verifies `templates/` folder is present with all necessary files

### Step 2: Ask for Project name
- Prompt the user for project name
- Validates the user input
- The project directory becomes `attendance_tracker_<input>`
- If the directory exists, system prompts whether to overwrite or not
	- `y` - Deletes old directory and creates a new one
	- `n` - leaves existing directory as is

### Step 3: Create file structure and copy fixed files
- Create `Helpers/` and `reports/` folders
- Copies `attendance_checker.py` to the project root and `config.json` into `Helpers/`

### Step 4: Build the roster
There are 2 options
- Option A(Copy from template) : Copies `n` students from the `templates/assets.csv`. 
- Option B(Generate a new roster): Create a new roster with saved array of students.

The script will then proceed to prompt the user how many students are there. 

>[!Note]
>**Total sessions** is the number of sessions including today, therefore the system expects:
>```bash
>Attendance Count + Absence Count  =  total_sessions − 1
>```
>In option A the number of **total sessions** found in `config.json` are 5 however in option B the number of **total sessions** is reset to 0 for the fresh roster


### Step 5: Set permissions
- Changes `attendance_checker.py` permissions to be writeable through code `chmod +x`
- `Helpers/config.json` permissions are updated to only allow the user read and write
- The script will print out permissions to verify
```bash
-rwxr-xr-x  ... attendance_checker.py
-rw-------  ... Helpers/config.json
```


### Step 6: Update alert thresholds
- System prompts the user if they want to update alert thresholds
	- `y` - asks the user for a new warning value and failure value
	- `n` - keeps the defaults (warning: 75, failure: 50)
- Verfies whether user input is within range of 0-100 and whether failure is lower than warning
- `sed` command is used to replace the values of only warning and failure in the `config.json` file


### Step 7: Verifies deployment
-System verfies deployment by automatically running the system feature 2



## Feature 2: Run the system
How it works
- It will first list the existing projects
- Prompt the user which project it would like to run
- It then validates the user input name and checks whether the project has the necessary files
- The system then changes directory to the project directory and run the following code
```bash
cd attendance_tracker_<user_input>
python3 attendance_checker.py
```

- Once the system successfully runs, it asks `[P]resent or [A]bsent?` for eah student and updates their count


## Feature 3: Archive logs

The Archiving is a manual action, you decide when to archive a sesion's logs. 

How it works
- Lists the existing projects and asks whih one you want to archive
- Validates the users answer and confirms that the `reports/` folder exists with necessary files inside. 
- Assign a timestamp variable in the format (`YYYYMMDD_HHMMSS`) so all archived files have the same timestamp
- For each log(`attendance.log`, `absent.log'):
	- If it exists, creates its own archive folder(`archives/attendance/` and `archives/absent/`) and moves it there with the timestamp in the name (`attendance_<timestamp>.log) or (`absent_<timestamp>.log`)
	- if it does not exist, the script reports `Nothing to archive` and continues. 
- Lastly it prints the path to each archived file and displays the total number of files archived


## Signal handling (CTRL+C/CTRL+Z)
While the deployment is in profress the user might want to press ctrl+c or ctrl+z to cancel or pause the program. The script won't abruptly stop, it will trap the signals and safely exist.

How it works
- The traps for both signals are set when feature 1 starts
- On either signal, the handler:
	1. Displays that the deployment was interrupted.
	2. Zips the incomplete project into `attendance_tracker_<name>_archive.zip`
	3. Deletes the incomplete project only if the zip file succeeded
	4. Displays `Exiting...` and then proceeds to exit the script
- Further signals are ignored until the first signal action is executed. 
- Once the deployment phase is over, all the traps are removed.


### What the `.zip` archive contains
The archive holds the incomplete project exactly as it was at the moment of interruption. Depending on how far the deployment could have gone it would include:
- `attendance_checker.py`
- `helpers/config.json`
- `Helpers/assets.csv`
- empty `reports/` folder

You can proceed to view the zipped file with 
```bash
unzip -l attendance_tracker_<name>_archive.zip
```

### How to test signal handling
1. Choose feature 1
2. Enter the project anem, then at the roster prompt press ctrl+c or ctrl+z
3. Confirm if the interupption message display and the zip path are displayed
4. Run the `ls -l` command to display whether the zip file was created
5. Proceed to unzip the file and inspect it
6. Repeat the interruption at the project name prompt (Nothing will be created)

## Testing
### Feature 1
Aspect | Test | Result
--- | --- | ---
Pre-flight checks | Run it with a template file missing | Clear message error
Deploy option A | Option A with 3 students | assets.csv has header +3 rows; the total sessions stay as 5
Deploy option B | Option B with 3 students | The attendance and absent count are set to 0; the total sessions is 1
Student count | Tested with 0, abc, empty space, and a number above the max | Rejected each with a message
Existing project | Answered with n | Process aborted with message
Existing project | Answered with y | Folder was overwritten
Existing project | Answered with any other digit | Failed with an error message
File permissions | Run `ls -l` command | Shows the script and config files with updated correct permissions
Update thresholds | Using valid values | Only warning and failure values were updated
Update thresholds | Tested with abc, exceeding range and with a higher failure value | Failed with a message
Verify deployment | Finish deployment | Automatically starts app

### Feature 2
Aspect | Test | Result
--- | --- | ---
Run | Mark each student present or absent | Counts update and logs appear
Run | Ctrl+C during marking | The app reports that progress is saved and script returns to menu

### Feature 3
Aspect | Test | Result
--- | --- | ---
Archive | Run with an absent student then archive | Both logs are archived with the same timestamp
Archive | Everynoe is present | Only `attendance` is archived and missing absent log is handled

### Signaling and others
Aspect | Test | Result
--- | --- | ---
Signals | Ctrl+C and Ctrl+Z at different points | zip is created, directory is removed and safely exit
Location | Start the script from a different directory | everything run accordingly
Menu | Enters an invalid unit | Error message and the menu is shown again
Menu | Ctrl+D | Script exits successfully


## Run-Through video

Link: 


## Author
Github: [dapoladpo](https://github.com/dapoladapo "dapoladapo")
