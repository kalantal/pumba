#!/bin/bash
#set -x

#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period

pumba_stop_containers() {
sudo ./pumba_linux_386 --random --interval 10s stop re2:test
}
pumba_stop_containers

exit 0
