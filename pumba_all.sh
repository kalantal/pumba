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

./pumba_chaos_standalone.sh $1 $2 pumba_kill
./pumba_chaos_standalone.sh $1 $2 pumba_pause
./pumba_chaos_standalone.sh $1 $2 pumba_stop
./pumba_chaos_standalone.sh $1 $2 pumba_rm
./pumba_chaos_standalone.sh $1 $2 pumba_delay
./pumba_chaos_standalone.sh $1 $2 pumba_netem_loss
./pumba_chaos_standalone.sh $1 $2 pumba_netem_rate

exit 0