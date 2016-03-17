#!/bin/sh

export QSUB_DEFAULT_OS=rel6

SUFFIX=$1

if [[ -z "${SUFFIX// }" ]]; then
  echo "Error: missing suffix"
  exit 1
fi

QUEUE_NAME=o_submit_32G_8H
LOCKUP=/home/kbukin/soft-lockup/lockup.pl
DIR_TREES_BASE=/home/scratch.mantolini_inf_1/konstantin/soft-lockup
DIR_LIST_BASE=/home/kbukin/soft-lockup
SLEEP_TIME=120

QSUB="qsub -q $QUEUE_NAME"

mkdir -p $DIR_TREES_BASE
mkdir -p $DIR_LIST_BASE

COUNTER=0
while [  $COUNTER -lt 1000 ]; do
  echo "********************"
  echo "* Counter=$COUNTER "
  echo "********************"

  DIR_TREES="$DIR_TREES_BASE/dirs-$SUFFIX-$COUNTER"
  DIR_LIST="$DIR_LIST_BASE/stat-$SUFFIX-$COUNTER.txt"

  #JOB_GEN_STR=`$QSUB $LOCKUP -stat_file $DIR_LIST -gen_tree $DIR_TREES`
  #JOB_GEN_ID=`echo $JOB_GEN_STR | perl -pe 's/Job <(\d+)>.*/$1/'`
  JOB_GEN_STR=`$QSUB -N -I $LOCKUP -stat_file $DIR_LIST -gen_tree $DIR_TREES 2>&1 >/dev/null | grep Starting`
  JOB_GEN_HOST=`echo $JOB_GEN_STR | perl -pe 's/.* on (.+)>>/$1/'`

  #JOB_STAT_STR=`$QSUB -w "ended($JOB_GEN_ID)" $LOCKUP -stat_file $DIR_LIST`
  JOB_STAT_STR=`$QSUB -R "select[hname != '$JOB_GEN_HOST']" $LOCKUP -stat_file $DIR_LIST`
  JOB_STAT_ID=`echo $JOB_STAT_STR | perl -pe 's/Job <(\d+)>.*/$1/'`

  $QSUB -w "ended($JOB_STAT_ID)" /bin/rm -rf $DIR_TREES $DIR_LIST

  echo "************************"
  echo "* Sleeping $SLEEP_TIME "
  echo "************************"
  sleep $SLEEP_TIME
  let COUNTER=COUNTER+1 
done

