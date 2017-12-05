#!/bin/bash
#set -x

export container=$1

#Remove target containers, with links and volumes

pumba_rm_containers() {
sudo ./pumba_linux_386 --interval 10s rm $container
}
pumba_rm_containers &>./results/pumba_results.log

exit 0
