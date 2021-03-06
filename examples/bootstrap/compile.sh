#!/bin/bash

#An example LSL build script. requires gcc's C preprocessor and bash
#on Windows, this most likely means a MinGW or Cygwin installation.

#optionally, you may also use lysol to obfuscate and validate your source code

#this script assumes a directory setup like the following by default:

# lsl_projects/
#   lib/ (where lib is the folder above this one)
#     examples/ # (this directory!)
#     (libraries)
#   (project)/
#     include/
#       (files to be #include'd)
#     compiled/
#       (compiled and obfuscated scripts)
#     (main script files)
#     (this compilation script)


###########
# OPTIONS #
###########

DEFINES="-DFOO"

#figure out where the actual compilation script is
SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`

#the path of the directory that contains the lsl stdlib
STDLIB_PATH=${BASEDIR}/../lib/

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
# compile <some file in the current dir>
compile main.lsl
