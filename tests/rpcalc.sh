#!/bin/sh
# Compile and run the rpcalc example that comes with bison
# This presumes you have 'make' available in boot and 'bison' in prod (from make install)
#
set -x

progdir=$( cd $( dirname $0 ); echo $PWD )

cd ${HOME}/zot/prod/bison || exit 99
. ./.env
cd ${HOME}/zot/boot/make || exit 99
. ./.env

cd "${progdir}"
rpcalcdir=$(find ../ -name rpcalc -type d | head -1)

cd ${rpcalcdir} || exit 99

#(export _CEE_RUNOPTS="DYNDUMP TRAP(OFF) $_CEE_RUNOPTS"; echo "4 9 +" | make run)
dbx $HOME/zopen/prod/bison/bin/bison -o y.tab.c --defines -Werror -Wall,dangling-alias --report=all --no-lines $HOME/zopen/dev/bisonport/bison-3.8/examples/c/calc/calc.y 

