#!/bin/bash
#set -x

#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation

pumba_netem_delay_containers() {
sudo ./pumba_linux_386 netem --duration 20s delay --time 3000 --jitter 100 re2:test
}
pumba_netem_delay_containers

exit 0


cd tools/
docker import iproute2.tar
docker load -i iproute2.tar

cd ..

pumba netem --duration 20s --tc-image gaiadocker/iproute2 delay --time 3000 jitter 50 --distribution normal $container



docker stop $(docker ps -a -q)
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
sudo docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm
sudo docker ps -a | grep Stop | cut -d ' ' -f 1 | xargs sudo docker rm >>./log




docker run -d --rm --name iproute2_test "gaiadocker/iproute2" tail -f /dev/null

sudo ./pumba_linux_386 netem --duration 20s --tc-image gaiadocker/iproute2 delay --time 3000 --jitter 100 re2:test
docker run -d --rm --name iproute2-test "gaiadocker/iproute2"

docker run -t -i ubuntu-alice /bin/bash

tar -xvf iproute2.tar | docker load