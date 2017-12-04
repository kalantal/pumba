#!/bin/bash
#set -x

export pumba_test=./pumba_linux_386

#Adds packet losses, based on independent (Bernoulli) probability model

pumba_netem_loss_containers() {
$pumba_test netem --duration 1m loss --percent 20 re2:test
}
pumba_netem_loss_containers

exit 0
