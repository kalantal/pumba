#!/bin/bash
#set -x

export container=$1

#Send termination signal to the main process inside target container(s)

pumba_kill_containers() {
sudo ./pumba_linux_386 kill $container
}
pumba_kill_containers &>./results/pumba_results.log

exit 0
