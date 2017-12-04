#!/bin/bash
#set -x

export pumba_test=./pumba_linux_386

#Remove target containers, with links and volumes

pumba_rm_containers() {
$pumba_test --random --interval 10s rm re2:test
}
pumba_rm_containers

exit 0
