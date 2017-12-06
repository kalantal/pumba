#!/bin/bash
#set -x

export container=$1
export pumba_results=./results/pumba_results.log

#Remove target containers, with links and volumes

echo -en "Pumba container rm test:\\n" 2>&1 | tee -a ./results/pumba_results.log

pumba_rm_containers() {
sudo ./pumba_linux_386 --interval 10s rm $container
}
pumba_rm_containers 2>&1 | tee -a ./results/pumba_results.log

exit 0
