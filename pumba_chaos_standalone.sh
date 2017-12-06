#!/bin/bash
#set -x

#Useage: ./pumba_master.sh [Container] [Duration before chaos] [Test to run]

export container_name=$1
export build_wait_time=$2
export complete_log=./results/complete.log
export pumba_results=./results/pumba_results.log

chmod +x ./*
chmod +x ./tests/*
chmod +x ./tools/*
chmod +x ./kill_scripts/*
chmod +x ./pumba_linux_386

#Validate paramaters
if (( $# < 3 )); then
	echo -en "Useage:\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_kill\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_delay\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_pause\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_stop\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_netem_loss\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_netem_rate\\n"
  exit 0
fi

docker_setup() {
#sudo groupadd docker
id -u "$USER" &>/dev/null || sudo groupadd docker
sudo gpasswd -a "$USER" docker
}
docker_setup

#Confirm clean enviornment
#Using Docker instead of Pumba
./tools/docker_nuke.sh

#Build the enviornment
docker_build_container() {
#x4 containers
echo -en "Building containers for [$container_name]:\\n"
#docker run -d --rm --name ubuntu-pumba "ubuntu" tail -f /dev/null
docker run -d --rm --name "$container_name"-pumba "$container_name" tail -f /dev/null
}
docker_build_container

#CLEAN RUN
echo 2>&1 | tee -a ./results/pumba_results.log

#TESTING RUN
#echo 2>&1 | tee -a ./results/pumba_results.log

echo -en "Pausing for [$build_wait_time] seconds to allow containers to spin up and tests to start.\\n"
sleep "$build_wait_time"

while [ $# -gt 0 ]; do
shift #this preserves the first argument $1 as the $container_name
	case "$1" in
		pumba_kill)
				./tests/pumba_kill.sh "$container_name"-pumba & ./kill_scripts/kill_kill.sh "$build_wait_time" &
				echo -en "Docker kill test:\\n"
				#Send termination signal to the main process inside target container(s)
				;;
		pumba_delay)
				./tests/pumba_delay.sh "$container_name"-pumba & ./kill_scripts/kill_delay.sh "$build_wait_time" &
				echo -en "Docker delay test:\\n"			
				#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
				;;
		pumba_pause)
				./tests/pumba_pause.sh "$container_name"-pumba & ./kill_scripts/kill_pause.sh "$build_wait_time" &
				echo -en "Docker pause test:\\n"
				#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period
				;;
		pumba_stop)
				./tests/pumba_stop.sh "$container_name"-pumba & ./kill_scripts/kill_stop.sh "$build_wait_time" &
				echo -en "Docker stop test:\\n"			
				#Remove target containers, with links and volumes
				;;
		pumba_rm)
				./tests/pumba_rm.sh "$container_name"-pumba & ./kill_scripts/kill_rm.sh "$build_wait_time" &
				echo -en "Docker rm test:\\n"			
				#Pause all running processes within target containers
				;;
		pumba_netem_loss)
				./tests/pumba_netem_loss.sh "$container_name"-pumba & ./kill_scripts/kill_netem_loss.sh "$build_wait_time" &
				echo -en "Docker netem_loss test:\\n"
				#Adds packet losses, based on independent (Bernoulli) probability model
				;;
		pumba_netem_rate)
				./tests/pumba_netem_rate.sh "$container_name"-pumba & ./kill_scripts/kill_netem_rate.sh "$build_wait_time" &
				echo -en "Docker netem_rate test:\\n"			
				#Rate limit egress traffic for specified containers
				;;
	esac
done

#Wait for tests
sleep "$build_wait_time" && echo -en "Done\\n"

docker_results_cleanup() {
#Remove top line
#sed -i '1d' $pumba_results

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
pumba_validation 2>&1 | tee -a $complete_log

#cat $complete_log
#cat $pumba_results

#Confirm clean enviornment
#Using Docker instead of Pumba
#./kill_scripts/kill_all.sh
./tools/docker_nuke.sh

exit 0
