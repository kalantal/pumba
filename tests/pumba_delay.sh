#!/bin/bash
#set -x

export container=$1

#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
#docker pull gaiadocker/iproute2 >iproute2.tar
#tar -xvf iproute2.tar | docker load

cd tools/
docker import iproute2.tar
docker load -i iproute2.tar
cd ..

pumba_netem_delay_containers() {
sudo ./pumba_linux_386 netem --duration 20s --tc-image gaiadocker/iproute2 delay --time 3000 jitter 50 --distribution normal $container
}
pumba_netem_delay_containers &>./results/pumba_results.log

exit 0
