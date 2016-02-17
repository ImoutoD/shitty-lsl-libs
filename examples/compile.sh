#!/bin/bash

###########
# OPTIONS #
###########

DEFINES="-DFOO"

#figure out where the actual compilation script is
SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`

#the path of the directory that contains the lsl stdlib
STDLIB_PATH=${BASEDIR}/..

#which program to use as the obfuscator
OBF_PROG="lysol"
#what options to pass to the obfuscator
OBF_OPTS="--O1"

#whether or not to pass the preprocessed script off to an obfuscator
OBFUSCATE=1

#whether or not to include line markers as comments in the preprocessed output
#(no LSL debuggers that I know of actually support these, they may be useful for
#manual debugging, though)
INCL_LINE_MARKERS=0

#extra options to pass to the c preprocessor
CPP_EXTRA_OPTS=""


#include the meat of the compilation script
. ${STDLIB_PATH}/lsl_buildscript.sh


###############
# BUILD STEPS #
###############

#clean up after the last compilation run
clean_compile

#compile our scripts
compile config-example.lsl
compile menu-example.lsl
# This is really fucked up.
#compile httplib-example.lsl
compile scrollbar-example.lsl
