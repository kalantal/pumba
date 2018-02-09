#!/bin/bash
#set -x

#Usage: ./pumba_master.sh [Container] [Duration before chaos] [Test to run]
#docker-enterprise-dev-local.artifactrepository.citigroup.net/cate-citisystems-soe-rhel/rhel7:2016q3_b0

export container_name=$1
export test_wait_time=$2
export test=$3
export complete_log=/tmp/pumba_complete.log
export pumba_results=/tmp/pumba_results.log
export watcher=/tmp/pumba_watcher.log
export kill_binary=./kill_binary.sh
export docker_nuke=./docker_nuke.sh

chmod +x ./*

docker_setup() {
#sudo groupadd docker
id -u "$USER" &>/dev/null || sudo groupadd docker
sudo gpasswd -a "$USER" docker
}
docker_setup

#Confirm clean environment using Docker instead of Pumba
"$docker_nuke"

docker_build_container() {
echo -en "Building containers for [$container_name]:\\n"
docker run -id --name "pumba_tester" "$container_name" tail -f /dev/null
}
#docker_build_container

docker_build_container

#CLEAN RUN
echo 2>&1 | tee "$pumba_results"

echo -en "Pausing for [$test_wait_time] seconds to allow containers to spin up and tests to start.\\n"
sleep "$test_wait_time"

while [ $# -gt 0 ]; do
shift
	case "$1" in
		pumba_kill)
				./pumba_kill.sh "Pumba_Tester"1 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Test - pumba_kill:\\n"
				#Send termination signal to the main process inside target container(s)
				;;
		pumba_delay)
				./pumba_delay.sh "Pumba_Tester"2 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Test - pumba_delay:\\n"			
				#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
				;;
		pumba_pause)
				./pumba_pause.sh "Pumba_Tester"3 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Test - pumba_pause:\\n"
				#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period
				;;
		pumba_stop)
				./pumba_stop.sh "Pumba_Tester"4 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Test - pumba_stop:\\n"			
				#Remove target containers, with links and volumes
				;;
		pumba_rm)
				./pumba_rm.sh "Pumba_Tester"5 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Test - pumba_rm:\\n"			
				#Pause all running processes within target containers
				;;
		pumba_netem_loss)
				./pumba_netem_loss.sh "Pumba_Tester"6 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Test - pumba_netem_loss:\\n"
				#Adds packet losses, based on independent (Bernoulli) probability model
				;;
		pumba_netem_rate)
				./pumba_netem_rate.sh "Pumba_Tester"7 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Test - pumba_netem_rate:\\n"
				#Rate limit egress traffic for specified containers
				;;
	esac
done

sed -i -e "/HERE/d" $pumba_results

pumba_validation() {
if grep "level=info" $pumba_results > /dev/null
then
	echo -en "Test(s) injection: Passed\\n"
else
	echo -en "Test(s) injection: Failed\\n"
fi
}
pumba_validation 2>&1 | tee $complete_log

echo 2>&1 | tee "$watcher"
docker logs pumba_tester > $watcher

"$kill_binary" "$test_wait_time"
"$docker_nuke"

exit 0
