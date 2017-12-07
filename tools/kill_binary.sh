#!/bin/bash
#set -x

export test_wait_time=$1

#pumba_linux_386 was not built to be automated. 
#pumba_linux_386 does not stop itself from running when tasks are complete.
#This initiates a forceful stop to the pumba related processes.

#sudo kill -9 `ps -aef | grep 'pumba_linux_386' | grep -v grep | awk '{print $2}'`

sleep "$test_wait_time"

pkill pumba_linux_386

exit 0