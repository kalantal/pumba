#!/bin/bash
#set -x

export container=$1
export test_wait_time=$2
export pumba_results=./results/pumba_results.log

#Run all avaliable container tests

echo -en "Pumba container kill test:\\n" 2>&1 | tee -a $pumba_results
timeout $test_wait_time ./pumba_linux_386 kill "$container"1 2>&1 | tee -a $pumba_results
sleep "$test_wait_time" && pkill pumba_linux_386

echo -en "Pumba container delay test:\\n" 2>&1 | tee -a $pumba_results
timeout $test_wait_time ./pumba_linux_386 netem --duration 20s --tc-image gaiadocker/iproute2 delay --time 3000 jitter 50 --distribution normal "$container"2 2>&1 | tee -a $pumba_results
sleep "$test_wait_time" && pkill pumba_linux_386

echo -en "Pumba container pause test:\\n" 2>&1 | tee -a $pumba_results
timeout $test_wait_time ./pumba_linux_386 pause --duration 10s "$container"3 2>&1 | tee -a $pumba_results
sleep "$test_wait_time" && pkill pumba_linux_386

echo -en "Pumba container stop test:\\n" 2>&1 | tee -a $pumba_results
timeout $test_wait_time ./pumba_linux_386 --interval 10s stop "$container"4 2>&1 | tee -a $pumba_results
sleep "$test_wait_time" && pkill pumba_linux_386

echo -en "Pumba container rm test:\\n" 2>&1 | tee -a $pumba_results
timeout $test_wait_time ./pumba_linux_386 --interval 10s rm "$container"5 2>&1 | tee -a $pumba_results
sleep "$test_wait_time" && pkill pumba_linux_386

echo -en "Pumba container netem loss test:\\n" 2>&1 | tee -a $pumba_results
timeout $test_wait_time ./pumba_linux_386 netem --duration 1m --tc-image gaiadocker/iproute2 loss --percent 20 "$container"6 2>&1 | tee -a $pumba_results
sleep "$test_wait_time" && pkill pumba_linux_386

echo -en "Pumba container netem rate test:\\n" 2>&1 | tee -a $pumba_results
timeout $test_wait_time ./pumba_linux_386 netem --duration 1m --tc-image gaiadocker/iproute2 rate "$container"7 2>&1 | tee -a $pumba_results
sleep "$test_wait_time" && pkill pumba_linux_386

exit 0
