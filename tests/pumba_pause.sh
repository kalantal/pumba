#!/bin/bash
#set -x

#Pause all running processes within target containers

pumba_pause_containers() {
sudo ./pumba_linux_386 --random --interval 10s pause re2:test
}
pumba_pause_containers

exit 0
