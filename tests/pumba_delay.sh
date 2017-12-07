#!/bin/bash
#set -x

export container=$1
export test_wait_time=$2
export pumba_results=./results/pumba_results.log

cd tools/
docker import iproute2.tar
docker load -i iproute2.tar
cd ..

#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
#docker pull gaiadocker/iproute2 >iproute2.tar
#tar -xvf iproute2.tar | docker load

echo -en "Pumba container delay test:\\n" 2>&1 | tee -a ./results/pumba_results.log

pumba_netem_delay_containers() {
./pumba_linux_386 netem --duration 20s --tc-image gaiadocker/iproute2 delay --time 3000 jitter 50 --distribution normal $container
}
pumba_netem_delay_containers 2>&1 | tee -a $pumba_results

exit 0
