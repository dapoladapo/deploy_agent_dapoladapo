# Deploy Agent Scripting



## Overview

This application is a script that if built with 3 features: to deploy, run and archive logs of a student attendance tracker. 

No. | Feature | Description
-----  | ----- | -----
1.  | Deploy  | This feature is built to check that all the requirements to run this system is set, builds out the system structure and sets up the ideal environment for the system to run. 
2.  | Run     | This feature will start the student attendance in a deployed project. 
3.  | Archive | This feature is will move all the active logs into an archived folder with timestamps. 



## Requirements to run the script

You would need 4 things

1. A computer system with Bash to run the script
2. Python3 needs to be installed
	- This is so it can run the 'attendance_checker.py' file
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
'1' | Feature 1: Deploy new project
'2' | Feature 2: Run the project
'3' | Feature 3: Archive log files from the project
'4' | Quit the system


## Feature 1: Deploy a new projects

### Step 1: Pre-flight checks
- Verifies 'python3' is installed
- Verifies 'zip' is installed
- Verifies 'templates/' folder is present with all necessary files

### Step 2: Ask for Project name
- Prompt the user for project name
- Validates the user input
- The project directory becomes 'attendance_tracker_<input>'
- If the directory exists, system prompts whether to overwrite or not
	- 'y' - Deletes old directory and creates a new one
	- 'n' - leaves existing directory as is

### Step 3: Create file structure and copy fixed files
- Create 'Helpers/' and 'reports/' folders
- Copies 'attendance_checker.py' to the project root and 'config.json' into 'Helpers/'

### Step 4: Build the roster
There are 2 options
- Option A(Copy from template) : Copies 'n' students from the 'templates/assets.csv'. 
- Option B(Generate a new roster): Create a new roster with saved array of students.

The script will then proceed to prompt the user how many students are there. 

>[!Note]
>**Total sessions** is the number of sessions including today, therefore hte system expects:
>```bash
>Attendance Count + Absence Count  =  total_sessions − 1
>```
>In option A the number of **total sessions** found in 'config.json' are 5 however in option B the number of **total sessions** is reset to 0 for the fresh roster


### Step 5: Set permissions
- Changes 'attendance_checker.py' permissions to be writeable through code `chmod +x`
- 'Helpers/config.json' permissions are updated to only allow the user read and write
- The script will print out permissions to verify
```bash
-rwxr-xr-x  ... attendance_checker.py
-rw-------  ... Helpers/config.json
```


### Step 6: Update alert thresholds
- System prompts the user if they want to update alert thresholds
	- 'y' - asks the user for a new warning value and failure value
	- 'n' - keeps the defaults (warning: 75, failure: 50)
- Verfies whether user input is within range of 0-100 and whether failure is lower than warning
- `sed` command is used to replace the values of only warning and failure in the `config.json` file


### Step 7: Verifies deployment
-System verfies deployment by automatically running the system feature 2



## Feature 2: Run the system

### Step 1: 
