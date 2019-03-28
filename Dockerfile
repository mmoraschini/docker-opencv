FROM ubuntu:bionic
LABEL maintainer="Marco Moraschini"

ENV DEBIAN_FRONTEND=noninteractive

ARG UID
ARG GID
ARG OPENCV_VERSION="4.0.1"
ARG PYTHON="OFF"

RUN echo "PYTHON = ${PYTHON}" \
	&& echo "OPENCV VERSION = ${OPENCV_VERSION}"

RUN if [ "${PYTHON}" != "ON" -a "${PYTHON}" != "OFF" ]; then \
	echo "The variable PYTHON must either be ON or OFF. Default OFF."; \
	exit 1; \
fi

# Required packages taken from https://docs.opencv.org/4.0.1/d7/d9f/tutorial_linux_install.html
# Added apt-utils, wget, gvim (vim-gtk) and a few extra
RUN apt update \
	&& apt install -y apt-utils build-essential cmake git pkg-config libgtk-3-dev wget vim-gtk sudo \
	&& apt install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev \
	&& apt install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev gfortran openexr libatlas-base-dev libdc1394-22-dev

RUN if [ "${PYTHON}" = "ON" ]; then \
	apt install -y python3-dev python3-pip python3-tk ipython3; \
	pip3 install numpy matplotlib scipy spyder pandas; \
fi

# This creates the directory if it doesn't exist 
WORKDIR opencv

RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
	&& unzip ${OPENCV_VERSION}.zip \
	&& rm ${OPENCV_VERSION}.zip \
	&& wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip \
	&& unzip ${OPENCV_VERSION}.zip \
	&& rm ${OPENCV_VERSION}.zip \
	&& wget https://github.com/opencv/opencv_extra/archive/${OPENCV_VERSION}.zip \
	&& unzip ${OPENCV_VERSION}.zip \
	&& rm ${OPENCV_VERSION}.zip

RUN if [ "${PYTHON}" = "OFF" ]; then \
	cd opencv-${OPENCV_VERSION} \
	&& mkdir build \
	&& cd build \
	&& cmake -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_INSTALL_PREFIX=/usr/local \
	-DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
	-DOPENCV_TEST_DATA_PATH=../../opencv_extra-${OPENCV_VERSION}/testdata \
	-DENABLE_CXX11=ON \
	-DINSTALL_C_EXAMPLES=ON \
	-DINSTALL_PYTHON_EXAMPLES=OFF \
	-DWITH_OPENGL=ON \
	-DWITH_OPENCL=ON \
	-DBUILD_TIFF=ON \
	-DWITH_IPP=ON \
	-DWITH_TBB=ON \
	-DWITH_EIGEN=ON \
	-DWITH_V4L=ON \
	-DBUILD_OPENCV_JAVA=OFF \
	-DWITH_CUDA=ON \
	-DBUILD_TESTS=ON \
	-DBUILD_PERF_TESTS=OFF \
	.. \
	&& make -j8 \
	&& make install; \
else \
	cd opencv-${OPENCV_VERSION} \
	&& mkdir build \
	&& cd build \
	&& cmake -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_INSTALL_PREFIX=/usr/local \
	-DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
	-DOPENCV_TEST_DATA_PATH=../../opencv_extra-${OPENCV_VERSION}/testdata \
	-DENABLE_CXX11=ON \
	-DINSTALL_C_EXAMPLES=ON \
	-DINSTALL_PYTHON_EXAMPLES=ON \
	-DWITH_OPENGL=ON \
	-DWITH_OPENCL=ON \
	-DBUILD_TIFF=ON \
	-DWITH_IPP=ON \
	-DWITH_TBB=ON \
	-DWITH_EIGEN=ON \
	-DWITH_V4L=ON \
	-DBUILD_OPENCV_JAVA=OFF \
	-DWITH_CUDA=OFF \
	-DBUILD_TESTS=ON \
	-DBUILD_PERF_TESTS=ON \
	-DPYTHON3_EXECUTABLE=$(which python3) \
	-DPYTHON_INCLUDE_DIR=$(python3-config --includes | cut -d' ' -f1 | cut -d'I' -f2-) \
	-DPYTHON_INCLUDE_DIR2=$(python3-config --includes | cut -d' ' -f2 | cut -d'I' -f2-) \
	-DPYTHON_LIBRARY=$(python3 -c "from distutils import sysconfig; v = sysconfig.get_config_vars(); print(v['LIBPL'] + '/' + v['LDLIBRARY'])") \
	-DPYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "import numpy as np; print(np.get_include())") \
	.. \
	&& make -j8 \
	&& make install; \
fi

# Create a new user that maps to the system user and add it to sudoers
# Its password will be dckr
RUN groupadd -g ${GID} dckr \
	&& useradd -rm -s /bin/bash -u ${UID} -g ${GID} dckr \
	&& echo dckr:dckr | chpasswd \
	&& adduser dckr sudo \
	&& echo "dckr ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Expose a few useful ports
EXPOSE 2000
EXPOSE 5000
EXPOSE 8888

USER dckr
