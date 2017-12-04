#!/bin/bash
#set -x

#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation

pumba_netem_delay_containers() {
sudo ./pumba_linux_386 netem --duration 20s delay --time 3000 jitter 50 re2:test
}
pumba_netem_delay_containers

exit 0
