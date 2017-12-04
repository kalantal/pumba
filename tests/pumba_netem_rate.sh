#!/bin/bash
#set -x

#Rate limit egress traffic for specified containers

pumba_netem_rate_containers() {
sudo ./pumba_linux_386 netem --duration 1m rate re2:test
}
pumba_netem_rate_containers

exit 0
