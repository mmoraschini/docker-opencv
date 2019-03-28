# Purpose
This repository contains a Dockerfile and a script to build a Docker image containing the OpenCV libraries.

# Features
The Dockerfile will create a default user inside the image (user: dckr, password: dckr) that maps to the user who ran the script. The script will also add a function (_cvdocker_) to the ~/.bashrc that will make it faster to run the container with the correct parameters.

# Running the script
To build the Docker image run _builder_\__script.sh_, you can check the help with

	./builder_script.sh -h

(if you cannot run the file remember to add the executable bit with _chmod +x builder_\__script.sh_).

To compile OpenCV with Pyhton support pass in "ON" (without quotes) as first argument. You can also set the OpenCV version with the second argument but note that this script was only tested with OpenCV 4.0.1
