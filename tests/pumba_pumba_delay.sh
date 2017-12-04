#!/bin/bash
#set -x

export pumba_test=./pumba_linux_386

#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation

pumba_netem_delay_containers() {
$pumba_test netem --duration 20s delay --time 3000 jitter 50 re2:test
}
pumba_netem_delay_containers
