#!/bin/bash
#set -x

export pumba_test=./pumba_linux_386

#Pause all running processes within target containers

pumba_pause_containers() {
$pumba_test --random --interval 10s pause re2:test
}
pumba_pause_containers

exit 0
