#!/bin/bash
#set -x

export container=$1
export pumba_results=./results/pumba_results.log

#Pause all running processes within target containers

echo -en "Pumba container pause test:\\n" 2>&1 | tee -a ./results/pumba_results.log

pumba_pause_containers() {
sudo ./pumba_linux_386 pause --duration 10s $container
}
pumba_pause_containers 2>&1 | tee -a ./results/pumba_results.log

exit 0
