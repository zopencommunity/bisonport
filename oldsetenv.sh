#!/bin/sh
#set -x

if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
else
	export _BPXK_AUTOCVT="ON"
	export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG),POSIX(ON),TERMTHDACT(MSG)"
	export _TAG_REDIR_ERR="txt"
	export _TAG_REDIR_IN="txt"
	export _TAG_REDIR_OUT="txt"

# Note to build bison you need to either use a tarball that is pre-configured
# or clone the code from git.
# 
# If you use the pre-configured bison source tarball, you need a 'bootstrap' bison
# and you need curl to pull down the tarball
#
# If you clone the code from git, you need to already have the Autotools installed
# on your system
#
# Specifying BISON_VRM of bison-1.4.19 will take the 'tarball' path
# Specifying BISON_VRM of bison will take the 'git' path
#
	gitsource=false 
	if $gitsource ; then
		export BISON_VRM="bison"
		export GIT_URL="https://git.savannah.gnu.org/git"
	else 
		export TARBALL_URL="http://ftp.gnu.org/gnu/bison"
		export BISON_VRM="bison-3.8"
	fi

	if [ "${MAKE_ROOT}x" = "x" ]; then
		export MAKE_ROOT="${HOME}/zot/prod/make"
	fi
	if [ "${M4_ROOT}x" = "x" ]; then
		export M4_ROOT="${HOME}/zot/prod/m4"
	fi
	if [ "${GZIP_ROOT}x" = "x" ]; then
		export GZIP_ROOT="${HOME}/zot/boot/gzip"
	fi
	if [ "${CURL_ROOT}x" = "x" ]; then
		export CURL_ROOT="${HOME}/zot/boot/curl"
	fi
	if [ "${BISON_INSTALL_PREFIX}x" = "x" ]; then
		export BISON_INSTALL_PREFIX="${HOME}/zot/prod/bison"   
	fi

	export MY_ROOT="${PWD}"
	export PATH="${M4_ROOT}/bin:${MAKE_ROOT}/bin:${GZIP_ROOT}/bin:${CURL_ROOT}/bin:${PATH}"
	export PATH="${MY_ROOT}/bin:${PATH}"
fi
