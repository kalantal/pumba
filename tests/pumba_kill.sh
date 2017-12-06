#!/bin/bash
#set -x

export container=$1
export pumba_results=./results/pumba_results.log

#Send termination signal to the main process inside target container(s)

echo -en "Pumba container kill test:\\n" 2>&1 | tee -a ./results/pumba_results.log

pumba_kill_containers() {
sudo ./pumba_linux_386 kill $container
}
pumba_kill_containers 2>&1 | tee -a ./results/pumba_results.log

exit 0
