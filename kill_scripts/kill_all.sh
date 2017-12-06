#!/bin/bash
#set -x

#pumba_linux_386 was not built to be automated. 
#pumba_linux_386 does not stop itself from running when tasks are complete.
#This initiates a forceful stop to the pumba related processes.

for pid in $(ps -fe | grep 'pumba' | grep -v grep | awk '{print $2}'); do
    sudo kill -9 "$pid"
done

#Old. Catches the grep containing and throws an error because it can't find itself.
#sudo kill -9 `ps aux | grep pumba | awk '{print $2}'`

exit 0