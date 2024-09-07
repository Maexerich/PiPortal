#!/bin/bash

### Inputs ###
# Path to requirements.txt file (unless it's in the same directory or further 'down', give absolute path)
REQUIREMENTS_FILE="requirements.txt"
# Directory where venv should be stored:
#   In WSL: be sure to have the leading "/" to ensure it refers to the home directory instead of creating a directory 'home' in the current directory.
#           example: "/home/max/.python_venv", where the folder '.python_venv' is where I store all my python virtual environments
DIRECTORY="/home/max/.python_venv"
# Name of virtual environment
VENV_NAME="PLR_python312"
# Path to Python interpreter --> be sure to give path to specific python version you wish to use. If you set it to "python", 
# it will use the default python version on your system
# In Windows for exmaple use: "C:\Users\maxgr\AppData\Local\Programs\Python\Python312\python.exe"
# In WSL you should be able to use the python version you want immediately, like: "python3.12". Test this using the terminal and the "python3.12 --version" command
PYTHON_INTERPRETER="python3.12"
# Python version you want to use (this won't enforce a version, but double-check it)
PYTHON_VERSION=3.12
# Flags to indicate whether you're using windows or linux (use 1 for true, 0 for false)
LINUX_FLAG="1"
WINDOWS_FLAG="0"
# Use "--show-packages" to show packages, or leave empty to skip this step
SHOW_PACKAGES_FLAG=$1
### End of Inputs ###


# Check if the directory exists, if not, create it
if [ ! -d "$DIRECTORY" ]; then
    mkdir -p "$DIRECTORY"
fi

# Activate virtual environment if it exists, otherwise create it
if [ $LINUX_FLAG == "1" ]; then
    ACTIVATION_COMMAND="source $DIRECTORY/$VENV_NAME/bin/activate"
    VENV_PYTHON="$DIRECTORY/$VENV_NAME/bin/python"
elif [ $WINDOWS_FLAG == "1" ]; then
    ACTIVATION_COMMAND="$DIRECTORY/$VENV_NAME/Scripts/activate"
    VENV_PYTHON="$DIRECTORY/$VENV_NAME/Scripts/python"
else
    echo "Please set the correct operating system flag!"
    exit 1
fi

if [ -d "$DIRECTORY/$VENV_NAME" ]; then
    echo "Activating existing virtual environment $VENV_NAME"
    source $ACTIVATION_COMMAND
else
    echo "Creating virtual environment $VENV_NAME"
    $PYTHON_INTERPRETER -m venv "$DIRECTORY/$VENV_NAME"
fi

# Check Python version
echo "Checking Python version:"
ACTUAL_PYTHON_VERSION=$("$VENV_PYTHON" --version | cut -d' ' -f2 | cut -d'.' -f1,2)
EXPECTED_PYTHON_VERSION_MAJOR_MINOR=$(echo "$PYTHON_VERSION" | cut -d'.' -f1,2)

if [ "$ACTUAL_PYTHON_VERSION" != "$EXPECTED_PYTHON_VERSION_MAJOR_MINOR" ]; then
    echo "Error: Incorrect Python version. Expected $EXPECTED_PYTHON_VERSION_MAJOR_MINOR but found $ACTUAL_PYTHON_VERSION"
    exit 1
else
    echo "Using correct Python version $PYTHON_VERSION"
fi

# Install packages from requirements.txt
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing packages from $REQUIREMENTS_FILE"
    "$VENV_PYTHON" -m pip install -r "$REQUIREMENTS_FILE"
else 
    echo "No requirements.txt file found at $REQUIREMENTS_FILE. Skipping package installation."
fi

# Print command to activate the virtual environment
echo "To activate the virtual environment, run:"
echo "source" \"$ACTIVATION_COMMAND\"
echo "To deactivate run the command: deactivate"

# Optionally display all installed packages in the virtual environment
if [ "$SHOW_PACKAGES_FLAG" == "--show-packages" ]; then
    echo "Installed packages in the virtual environment:"
    "$VENV_PYTHON" -m pip list
fi

echo " --- Virtual environment setup complete ---"
