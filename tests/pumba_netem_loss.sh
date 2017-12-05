#!/bin/bash
#set -x

export container=$1

#Adds packet losses, based on independent (Bernoulli) probability model

cd tools/
docker import iproute2.tar
docker load -i iproute2.tar
cd ..

pumba_netem_loss_containers() {
sudo ./pumba_linux_386 netem --duration 1m --tc-image gaiadocker/iproute2 loss --percent 20 $container
}
pumba_netem_loss_containers &>./results/pumba_results.log

exit 0
