#!/bin/bash
#set -x

export container=$1
export test_wait_time=$2
export pumba_results=./results/pumba_results.log

cd tools/
docker import iproute2.tar
docker load -i iproute2.tar
cd ..

#Rate limit egress traffic for specified containers

echo -en "Pumba container netem rate test:\\n" 2>&1 | tee -a $pumba_results

pumba_netem_rate_containers() {
./pumba_linux_386 netem --duration 1m --tc-image gaiadocker/iproute2 rate $container
}
pumba_netem_rate_containers 2>&1 | tee -a $pumba_results

exit 0
