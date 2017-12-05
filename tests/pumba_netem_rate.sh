#!/bin/bash
#set -x

export container=$1

#Rate limit egress traffic for specified containers

cd tools/
docker import iproute2.tar
docker load -i iproute2.tar
cd ..

pumba_netem_rate_containers() {
sudo ./pumba_linux_386 netem --duration 1m --tc-image gaiadocker/iproute2 rate $container
}
pumba_netem_rate_containers &>./results/pumba_results.log

exit 0
