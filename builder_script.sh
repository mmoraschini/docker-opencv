#!/bin/bash

if ([ $# == 1 ] && [ $1 == '-h' -o $1 == '--help' ]); then
	echo "USAGE:";
	echo "builder_script.sh [INSTALL_PYTHON: (OFF)/ON] [OPENCV_VERSION: 4.0.1]";
	echo -e "\nN.B.: This script was only tested with opencv 4.0.1"
	exit 0;
fi

INSTALL_PYTHON="OFF"
OPENCV_VERSION="4.0.1"

if [ $# == 1 ]; then
	INSTALL_PYTHON=$1;
fi

if [ $# == 2 ]; then
	OPENCV_VERSION=$2;
fi

function check_bashrc() {
	while read -r l; do
		if [ "$l" = "# >>> docker-opencv script >>>" ]; then
			echo "Function cvdocker already added to ~/.bashrc. Skipping."
			return 1
		fi
	done < ~/.bashrc

	return 0
}

function add_to_bashrc() {
	echo "Adding function cvdocker to ~/.bashrc"

	{
		echo -e "# Line added by docker-opencv builder script"
		echo -e "# >>> docker-opencv script >>>"
		echo -e "function cvdocker() {"
		echo -e "\tdocker container run \\"
		echo -e "\t-v /home/\${USER}:/home/dckr \\"
		echo -e "\t-v /tmp/.X11-unix:/tmp/.X11-unix \\"
		echo -e "\t--workdir /home/dckr \\"
		echo -e "\t-e DISPLAY=\${DISPLAY} \\"
		echo -e "\t-p 5000:5000 -p 8888:8888 -p 2000:2000\\"
		echo -e "\t-it docker_opencv_image /bin/bash"
		echo -e "}"
		echo -e "# <<< docker-opencv script <<<\n"
	} >> ~/.bashrc

	echo "Done! You can now run the container simply by typing 'cvdocker'. If it doesn't work reload the .bashrc with 'source ~/.bashrc'"
}

echo "Starting docker build"
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg PYTHON=${INSTALL_PYTHON} --build-arg OPENCV_VERSION=${OPENCV_VERSION} --tag=docker_opencv_image . \
	&& check_bashrc \
	&& add_to_bashrc
