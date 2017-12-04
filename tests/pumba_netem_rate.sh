#!/bin/bash
#set -x

export pumba_test=./pumba_linux_386

#Rate limit egress traffic for specified containers

pumba_netem_rate_containers() {
$pumba_test netem --duration 1m rate re2:test
}
pumba_netem_rate_containers

exit 0
