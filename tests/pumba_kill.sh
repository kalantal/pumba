#!/bin/bash
#set -x

#Send termination signal to the main process inside target container(s)

pumba_kill_containers() {
sudo ./pumba_linux_386 --random --interval 10s kill re2:^test
}
pumba_kill_containers

exit 0
