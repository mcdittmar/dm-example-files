#!/bin/sh
# ================================================================================
# Executes some sample test runs of the voefg utility.
#   TEST* variables expected to be set in user environment
# ================================================================================

this=$0

tool="voefg"

EXEC=${tool}

echo "Test ${tool} tool"


commands=("${EXEC} infile=${TESTIN}/test_eventlist.fits outdir=${TESTOUT} outfile=voefg_test00.out template=${TESTRES}/test_template.db format=xxx clobber+ verbose=2"
          "${EXEC} infile=${TESTIN}/test_eventlist.fits outdir=${TESTOUT} outfile=- template=${TESTRES}/test_template.db format=xxx clobber+ verbose=2"
          "${EXEC} infile=${TESTIN}/test_eventlist.fits outdir=${TESTOUT} outfile=- template=${TESTRES}/test_template.db format=vot clobber+ verbose=2"
          "${EXEC} infile=${TESTIN}/test_eventlist.fits outdir=${TESTOUT} outfile=- template=${TESTRES}/test_template.db format=avot clobber+ verbose=2"
          "${EXEC} infile=${TESTIN}/test_eventlist.fits outdir=${TESTOUT} outfile=- template=${TESTRES}/test_template.db format=xml clobber+ verbose=2"
         )
logfiles=("test00.log"
          "test01.log"
          "test02.log"
          "test03.log"
          "test04.log"
         )
outfiles=("voefg_test00.out"
          "test_eventlist.xxx"
          "test_eventlist.vot"
          "test_eventlist.avot"
          "test_eventlist.xml"
         )

# Make sure output directory exists
mkdir -p ${TESTOUT}

for ii in `seq 0 4`
do
    grade="FAIL"

    command=${commands[$ii]}
    echo "COMMAND $ii: $command"
    $command > ${TESTOUT}/${logfiles[$ii]}
    if [[ "$?" = "0" ]]
    then
  	diff -q ${TESTSAV}/${outfiles[$ii]} ${TESTOUT}/${outfiles[$ii]} 
        if [[ "$?" = "0" ]]
        then
            grade="PASS"
  	    rm -f ${TESTOUT}/${logfiles[$ii]}
  	    rm -f ${TESTOUT}/${outfiles[$ii]}
        fi
    fi
    echo "  Test $ii: ${grade}"
done
