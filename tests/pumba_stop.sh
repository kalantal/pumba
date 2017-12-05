#!/bin/bash
#set -x

export container=$1

#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period

pumba_stop_containers() {
sudo ./pumba_linux_386 --interval 10s stop ubuntu-pumba $container
}
pumba_stop_containers &>./results/pumba_results.log

exit 0
