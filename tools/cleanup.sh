#!/bin/bash

docker unpause $(docker ps -a -q)
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm
docker ps -a | grep Stop | cut -d ' ' -f 1 | xargs sudo docker rm
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

sudo pgrep pumba
sudo pkill pumba_linux_386
sudo pgrep pumba

exit 0
