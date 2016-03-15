#!/bin/sh

export QSUB_DEFAULT_OS=rel6

SUFFIX=$1

QUEUE_NAME=o_cpu_4G_1H
LOCKUP=/home/kbukin/soft_lockup/lockup.pl
DIR_TREES_BASE=/home/scratch.mantolini_inf_1/konstantin/soft_lockup
DIR_LIST_BASE=/home/kbukin/soft_lockup

COUNTER=0
while [  $COUNTER -lt 1000 ]; do
  echo "****************"
  echo Counter=$COUNTER
  echo "****************"

  DIR_TREES="$DIR_TREES_BASE/dirs-$SUFFIX-$COUNTER"
  DIR_LIST="$DIR_LIST_BASE/stat-$SUFFIX-$COUNTER.txt"

  JOB_GEN_STR=`qsub -P kepler -q $QUEUE_NAME $LOCKUP -stat_file $DIR_LIST -gen_tree $DIR_TREES`
  JOB_GEN_ID=`echo $JOB_GEN_STR | perl -pe 's/Job <(\d+)>.*/$1/'`


  JOB_STAT_STR=`qsub -P kepler -q $QUEUE_NAME -w "ended($JOB_GEN_ID)" $LOCKUP -stat_file $DIR_LIST`
  JOB_STAT_ID=`echo $JOB_STAT_STR | perl -pe 's/Job <(\d+)>.*/$1/'`

  qsub -P kepler -q $QUEUE_NAME -w "ended($JOB_STAT_ID)" /bin/rm -rf $DIR_TREES $DIR_LIST

  sleep 120
  let COUNTER=COUNTER+1 
done

