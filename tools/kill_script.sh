#!/bin/bash

export build_wait_time=$1

sleep $build_wait_time

sudo kill -9 `ps aux | grep pumba | awk '{print $2}'`

exit 0
