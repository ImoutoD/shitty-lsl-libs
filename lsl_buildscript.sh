function compile
{
  echo "Compiling: ${1}"

  #make sure the directory where we'll put the compiled scripts exists
  mkdir -p  `dirname ${BASEDIR}/compiled/${1}`

  DEST_PATH=${BASEDIR}/compiled/${1}.lsl_c

  #I still replace # with // in case you're actually using line markers
  cpp -x c++ -E -nostdinc ${CPP_EXTRA_OPTS} -I${BASEDIR}/include/ -I${STDLIB_PATH} ${DEFINES} $1 | sed -r 's/^#/\/\/#/' > ${DEST_PATH}

  if [ $OBFUSCATE -eq 1 ]; then
    ocompile $1
  fi
}

function ocompile
{
  if [[ $OSTYPE == 'cygwin' ]]; then
    DEST_PATH=`cygpath -w ${BASEDIR}/compiled/${1}.lsl_c`
    OBF_PATH=`cygpath -w ${BASEDIR}/compiled/${1}.lsl_o`
  else
    DEST_PATH=${BASEDIR}/compiled/${1}.lsl_c
    OBF_PATH=${BASEDIR}/compiled/${1}.lsl_o
  fi
  echo "Running '${OBF_PROG} ${OBF_OPTS} ${DEST_PATH}'"
  ${OBF_PROG} ${OBF_OPTS} ${DEST_PATH} > ${OBF_PATH}
}

function clean_compile
{
  rm -rf ${BASEDIR}/compiled/*
}

if [ $INCL_LINE_MARKERS -eq 0 ]; then
  CPP_EXTRA_OPTS=${CPP_EXTRA_OPTS}" -P"
fi
