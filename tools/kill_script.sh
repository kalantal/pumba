#!/bin/bash

#pumba_linux_386 was not built to be automated. 
#pumba_linux_386 does not stop itself from running when tasks are complete.
#This initiates a forceful stop to the pumba related processes.

export build_wait_time=$1

sleep $build_wait_time

for pid in $(ps -fe | grep '[p]umba' | grep -v grep | awk '{print $2}'); do
    kill "$pid"
done

#Old. Catches the grep containing and throws an error because it can't find itself.
#sudo kill -9 `ps aux | grep pumba | awk '{print $2}'`

exit 0
