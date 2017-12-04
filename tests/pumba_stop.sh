#!/bin/bash
#set -x

export pumba_test=./pumba_linux_386

#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period

pumba_stop_containers() {
$pumba_test --random --interval 10s stop re2:test
}
pumba_stop_containers

exit 0
