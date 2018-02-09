#!/bin/bash
#set -x

#Usage: ./pumba_master.sh [Container] [Duration before chaos] [Test to run]

export container_name=$1
export test_wait_time=$2
export test=$3
export complete_log=./results/pumba_complete.log
export pumba_results=./results/pumba_results.log
export watcher_log=./results/pumba_watcher.log
export kill_binary=./tools/kill_binary.sh
export docker_nuke=./tools/docker_nuke.sh

chmod +x ./tests/*
chmod +x ./tools/*
chmod +x ./pumba_linux_386

#Validate parameters
if (( "$#" < 3 )) || [ "$1" == -help ] || [ "$1" == --help ] || [ "$1" == help ]; then
	echo -en "Chaos testing for docker containers\\n"
	echo -en "\\nUseage:\\n"
	echo -en "  ./pumba_chaos.sh [CONTAINER] [TIME TO RUN TESTS] [TEST TO RUN]\\n"
	echo -en "  ./pumba_chaos.sh help\\n\\n"	
	echo -en "Container Options:\\n"	
	echo -en "  Choose a container from the Citi docker repo\\n"
	echo -en "  This container should be running your test payload\\n"
	echo -en "  ex: rhel7\\n\\n"
	echo -en "Time:\\n"
	echo -en "  It is recommended that you inject these pumba tests when your container test payload is running\\n"
	echo -en "  The minimum recommended time to use is 15 seconds before injection\\n"
	echo -en "  Most test cases will not take place this soon\\n"
	echo -en "  Time is selected as a plain digits in the format of seconds\\n"
	echo -en "  ex: 60\\n\\n"
	echo -en "Test Options:\\n"
	echo -en "  pumba_all		Run all available container tests\\n"	
	echo -en "  pumba_kill		Send termination signal to the main process inside target container(s)\\n"
	echo -en "  pumba_delay		Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation\\n"
	echo -en "  pumba_pause		Pause all running processes within target containers\\n"
	echo -en "  pumba_rm		Remove target containers, with links and volumes\\n"
	echo -en "  pumba_ stop		Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period\\n"
	echo -en "  pumba_netem_loss	Adds packet losses, based on independent (Bernoulli) probability model\\n"
	echo -en "  pumba_netem_rate	Rate limit egress traffic for specified containers\\n\\n"
	echo -en "Example usage:\\n"
	echo -en "  ex: ./pumba_chaos.sh rhel7 60 pumba_all\\n"
	echo -en "  ex: ./pumba_chaos.sh rhel7 60 pumba_kill\\n"
	echo -en "  ex: ./pumba_chaos.sh rhel7 60 pumba_delay\\n"
	echo -en "  ex: ./pumba_chaos.sh rhel7 60 pumba_pause\\n"
	echo -en "  ex: ./pumba_chaos.sh rhel7 60 pumba_stop\\n"
	echo -en "  ex: ./pumba_chaos.sh rhel7 60 pumba_netem_loss\\n"
	echo -en "  ex: ./pumba_chaos.sh rhel7 60 pumba_netem_rate\\n\\n"
  exit 0
fi

docker_setup() {
#sudo groupadd docker
id -u "$USER" &>/dev/null || sudo groupadd docker
sudo gpasswd -a "$USER" docker
}
docker_setup

#Confirm clean environment using Docker instead of Pumba
"$docker_nuke"

#Build a single container
docker_build_container() {
echo -en "Building containers for [$container_name]:\\n"
docker run -d --name "Pumba_Tester"1 "$container_name" tail -f /dev/null
}
#docker_build_container
#docker-enterprise-dev-local.artifactrepository.citigroup.net/cate-citisystems-soe-rhel/rhel7:2016q3_b0

#Build multiple containers
docker_build_container_all() {
echo -en "Building containers for [$container_name]:\\n"
for i in {1..7}; do docker run -d --name "Pumba_Tester"$i "$container_name" tail -f /dev/null; done
}
#docker_build_container_all

#Only build container equal to the number of tests requested
if [ "$test" = pumba_all ] ; then
	docker_build_container_all
else
	docker_build_container
fi

#CLEAN RUN
echo 2>&1 | tee $watcher_log

#TESTING RUN
#echo 2>&1 | tee -a watcher_log

echo -en "Pausing for [$test_wait_time] seconds to allow containers to spin up and tests to start.\\n"
sleep "$test_wait_time"

while [ $# -gt 0 ]; do
shift #this preserves the first argument $1 as the $container_name
	case "$1" in
		pumba_kill)
				./tests/pumba_kill.sh "Pumba_Tester"1 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker kill test:\\n"
				#Send termination signal to the main process inside target container(s)
				;;
		pumba_delay)
				./tests/pumba_delay.sh "Pumba_Tester"2 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker delay test:\\n"			
				#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
				;;
		pumba_pause)
				./tests/pumba_pause.sh "Pumba_Tester"3 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker pause test:\\n"
				#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period
				;;
		pumba_stop)
				./tests/pumba_stop.sh "Pumba_Tester"4 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker stop test:\\n"			
				#Remove target containers, with links and volumes
				;;
		pumba_rm)
				./tests/pumba_rm.sh "Pumba_Tester"5 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker rm test:\\n"			
				#Pause all running processes within target containers
				;;
		pumba_netem_loss)
				./tests/pumba_netem_loss.sh "Pumba_Tester"6 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker netem_loss test:\\n"
				#Adds packet losses, based on independent (Bernoulli) probability model
				;;
		pumba_netem_rate)
				./tests/pumba_netem_rate.sh "Pumba_Tester"7 "$test_wait_time" & "$kill_binary" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker netem_rate test:\\n"
				#Rate limit egress traffic for specified containers
				;;
		pumba_all)
				./tests/pumba_all.sh "$container_name" "$test_wait_time" && sleep "$test_wait_time" && echo -en "Done\\n"
				echo -en "Docker test suite:\\n"
				echo -en "kill, pause, stop, rm, delay, netem_loss, netem_rate\\n"
				#Do all
				;;
	esac
done

docker_results_cleanup() {
#Remove top line
sed -i '1d' $pumba_results

#Remove empty commands
sed -i -e "/HERE/d" $pumba_results
sed -i -e "/Remove containers/d" $pumba_results
sed -i -e "/Stop containers/d" $pumba_results
sed -i -e "/Kill containers/d" $pumba_results
sed -i -e "/Pause containers/d" $pumba_results
sed -i -e "/netem: delay/d" $pumba_results
sed -i -e "/netem: loss/d" $pumba_results
sed -i -e "/netem: rate/d" $pumba_results
}
docker_results_cleanup

pumba_validation() {
#If this shows up after all the empty command removal, the suite ran
if grep "level=info" $pumba_results > /dev/null
then
	echo -en "Test(s) injected sucessfully\\n"
else
	echo -en "Test(s) injection failed\\n"
fi
}
pumba_validation 2>&1 | tee $complete_log

#cat $complete_log
#cat $pumba_results

echo 2>&1 | tee "$watcher"
docker logs pumba_tester > $watcher

#Cleanup using Docker
"$kill_binary" "$test_wait_time"
"$docker_nuke"

exit 0
