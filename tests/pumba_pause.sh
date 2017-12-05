#!/bin/bash
#set -x

export container=$1

#Pause all running processes within target containers

pumba_pause_containers() {
sudo ./pumba_linux_386 pause --duration 10s $container
}
pumba_pause_containers &>./results/pumba_results.log

exit 0
