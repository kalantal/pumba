#!/bin/bash
#set -x

#Adds packet losses, based on independent (Bernoulli) probability model

pumba_netem_loss_containers() {
sudo ./pumba_linux_386 netem --duration 1m loss --percent 20 re2:test
}
pumba_netem_loss_containers

exit 0
