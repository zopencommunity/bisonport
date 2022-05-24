#!/bin/sh 
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to xlclang
#  - either pre-install the BISON tar ball into MY_ROOT or have curl/gunzip installed for auto-download
#
#set -x

if [ "${MY_ROOT}" = '' ]; then
	echo "Need to set MY_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${BISON_VRM}" = '' ]; then
	echo "Need to set BISON_VRM - source setenv.sh" >&2
	exit 16
fi

if ! make --version >/dev/null 2>&1 ; then
	echo "You need GNU Make on your PATH in order to build BISON" >&2
	exit 16
fi

if ! whence xlclang >/dev/null ; then
	echo "xlclang required to build BISON. " >&2
	exit 16
fi

cd "${MY_ROOT}" || exit 99

if [ "${GIT_URL}x" != "x" ]; then
	if ! [ -d "${BISON_VRM}" ] ; then 
		export GIT_SSL_CAINFO=${MY_ROOT}/git-savannah-gnu-org-chain.pem
		if ! git clone "${GIT_URL}/${BISON_VRM}.git" ; then
			exit 4
		fi
		cd "${BISON_VRM}" || exit 99
		cd "${MY_ROOT}" || exit 99
	fi
else
	# Non-dev - get the tar file
	if [ "${TARBALL_URL}" = '' ]; then
		echo "Need to set BISON_URL - source setenv.sh" >&2
		exit 16
	fi

	rm -rf "${BISON_VRM}"
	if ! mkdir -p "${BISON_VRM}"; then
		echo "Unable to make root BISON directory: ${MY_ROOT}/${BISON_VRM}" >&2
		exit 16
	fi

	if ! [ -f "${BISON_VRM}.tar" ]; then
		echo "bison tar file not found. Attempt to download with curl" 
		if ! whence curl >/dev/null ; then
			echo "curl not installed. You will need to upload BISON, or install curl/gunzip from ${BISON_URL}" >&2
			exit 16
		fi	
		if ! whence gunzip >/dev/null ; then
			echo "gunzip required to unzip BISON. You will need to upload BISON, or install curl/gunzip from ${BISON_URL}" >&2
			exit 16
		fi	
		if ! (rm -f ${BISON_VRM}.tar.gz; curl -s --output ${BISON_VRM}.tar.gz ${TARBALL_URL}/${BISON_VRM}.tar.gz) ; then
			echo "curl failed with rc $rc when trying to download ${BISON_VRM}.tar.gz" >&2
			exit 16
		fi	
		chtag -b ${BISON_VRM}.tar.gz
		if ! gunzip ${BISON_VRM}.tar.gz ; then 
			echo "gunzip failed with rc $rc when trying to unzip ${BISON_VRM}.tar.gz" >&2
			exit 16
		fi	
	fi

	tar -xf "${BISON_VRM}.tar" 2>/dev/null
#
# TBD: figure out how to untar the tar file without errors about setting uid/gid
#
	if [ $? -gt 1 ]; then
		echo "Unable to untar BISON drop: ${BISON_VRM}" >&2
		exit 16
	fi
fi

if ! chtag -R -h -t -cISO8859-1 "${BISON_VRM}"; then
	echo "Unable to tag BISON directory tree as ASCII" >&2
	exit 16
fi

DELTA_ROOT="${PWD}"

cd "${MY_ROOT}/${BISON_VRM}" || exit 99

#
# Apply patches
#
if ! managepatches.sh ; then
	echo "Unable to patch BISON tree" >&2
	exit 16
fi

if [ "${BISON_VRM}" = "bison" ]; then
	./bootstrap
	if [ $? -gt 0 ]; then
		echo "Bootstrap of BISON dev-line failed." >&2
		exit 16
	fi
fi

#
# Setup the configuration so that the system search path looks in lib and include ahead of the standard C libraries
#
export CC=xlclang
export CFLAGS="-DNSIG=39 -std=gnu11 -qascii -D_XOPEN_SOURCE=600 -D_AE_BIMODAL=1 -D_ALL_SOURCE -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -qnose -qfloat=ieee -I${MY_ROOT}/${BISON_VRM},${MY_ROOT}/${BISON_VRM}/lib,/usr/include"

./configure --prefix="${BISON_INSTALL_PREFIX}"
if [ $? -gt 0 ]; then
	echo "Configure of BISON tree failed." >&2
	exit 16
fi

cd "${MY_ROOT}/${BISON_VRM}" || exit 99
if ! make ; then
	echo "MAKE of BISON tree failed." >&2
	exit 16
fi

if ! make check ; then
	echo "MAKE of BISON tree failed." >&2
	exit 16
fi

cd "${DELTA_ROOT}/tests"
export PATH="${MY_ROOT}/${BISON_VRM}/src:${PATH}"

if ! ./runbasic.sh ; then
	echo "Basic test of BISON failed." >&2
	exit 16
fi
if ! ./runexamples.sh ; then
	echo "Example tests of BISON failed." >&2
	exit 16
fi

cd "${MY_ROOT}/${BISON_VRM}" || exit 99
if ! make install ; then
	echo "Make install of BISON failed." >&2
	exit 16
fi

echo "BISON installed into ${BISON_INSTALL_PREFIX}"

exit 0
