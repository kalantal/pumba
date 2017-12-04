#!/bin/bash
#set -x

export pumba_test=./pumba_linux_386

#Send termination signal to the main process inside target container(s)

pumba_kill_containers() {
sudo $pumba_test --random --interval 10s kill re2:test
}
pumba_kill_containers

exit 0
