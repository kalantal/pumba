#!/bin/bash
#set -x

#Useage: ./pumba_master.sh [Container] [Duration before chaos]

export container_name=$1
export build_wait_time=$2

if (( $# < 2 )); then
	echo -en "Useage:\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60\\n"
  exit 0
fi

#CLEAN RUN
echo 2>&1 | tee ./results/pumba_results.log

bash ./pumba_chaos_standalone.sh "$1" "$2" pumba_kill
bash ./pumba_chaos_standalone.sh "$1" "$2" pumba_pause
bash ./pumba_chaos_standalone.sh "$1" "$2" pumba_stop
bash ./pumba_chaos_standalone.sh "$1" "$2" pumba_rm
bash ./pumba_chaos_standalone.sh "$1" "$2" pumba_delay
bash ./pumba_chaos_standalone.sh "$1" "$2" pumba_netem_loss
bash ./pumba_chaos_standalone.sh "$1" "$2" pumba_netem_rate

exit 0
