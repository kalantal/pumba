#!/bin/bash
#set -x

export container=$1
export test_wait_time=$2
export pumba_results=./results/pumba_results.log

#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period

echo -en "Pumba container stop test:\\n" 2>&1 | tee -a ./results/pumba_results.log

pumba_stop_containers() {
./pumba_linux_386 --interval 10s stop ubuntu-pumba $container
}
pumba_stop_containers 2>&1 | tee -a $pumba_results

exit 0
