#!/bin/bash
#set -x

#Remove target containers, with links and volumes

pumba_rm_containers() {
sudo ./pumba_linux_386 --random --interval 10s rm re2:test
}
pumba_rm_containers

exit 0
