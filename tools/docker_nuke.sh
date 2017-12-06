#!/bin/bash
#set -x

for var in list
do
		docker unpause $(docker ps -a -q) > /dev/null 2>&1
		docker stop $(docker ps -a -q) > /dev/null 2>&1
		docker rm $(docker ps -a -q) > /dev/null 2>&1
		docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm > /dev/null 2>&1
		docker ps -a | grep Stop | cut -d ' ' -f 1 | xargs sudo docker rm > /dev/null 2>&1
		docker rmi $(docker images --filter "dangling=true" -q --no-trunc) > /dev/null 2>&1
done

exit 0
