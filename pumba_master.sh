#!/bin/bash
#set -x

#useage:
#./pumba_master.sh ubuntu 60 pumba_kill

export container_name=$1
export build_wait_time=$2
#results moved to ./tests/* because of issues re-directing log after variables in cases 
#export log=.tools/pumba_results.log


chmod +x ./*
chmod +x ./tests/*
chmod +x ./tools/*
chmod +x ./pumba_linux_386

docker_setup() {
#sudo groupadd docker
id -u "$user" &>/dev/null || sudo groupadd docker
sudo gpasswd -a "$USER" docker
}
docker_setup

#Validate paramaters
if [ -z "$*" ] && [[ -z "$*" ]] && [[ -z "$*" ]] ; then
	echo -en "No argeuments supplied. You must specify which container to use and which test to run\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_kill\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_delay\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_pause\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_stop\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_netem_loss\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 pumba_netem_rate\\n"
  exit 0
fi

#Build the enviornment
docker_build_container() {
#x4 containers
echo -en "Building containers for [$container_name]:\\n"
#docker run -d --rm --name ubuntu-pumba "ubuntu" tail -f /dev/null
docker run -d --rm --name $container_name-pumba "$container_name" tail -f /dev/null
}
docker_build_container

echo -en "Pausing for [$build_wait_time] seconds to allow containers to spin up and tests to start.\\n"
sleep $build_wait_time

while [ $# -gt 0 ]; do
shift #this preserves the first argument $1 as the $container_name
	case "$1" in
		pumba_kill)
				./tests/pumba_kill.sh $container_name-pumba & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker kill test:\\n"
				#Send termination signal to the main process inside target container(s)
				;;
		pumba_delay)
				./tests/pumba_delay.sh $container_name-pumba & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker delay test:\\n"			
				#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
				;;
		pumba_pause)
				./tests/pumba_pause.sh $container_name-pumba & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker pause test:\\n"
				#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period
				;;
		pumba_stop)
				./tests/pumba_stop.sh $container_name-pumba & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker stop test:\\n"			
				#Remove target containers, with links and volumes
				;;
		pumba_rm)
				./tests/pumba_rm.sh $container_name-pumba & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker rm test:\\n"			
				#Pause all running processes within target containers
				;;
		pumba_netem_loss)
				./tests/pumba_netem_loss.sh $container_name-pumba & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker netem_loss test:\\n"
				#Adds packet losses, based on independent (Bernoulli) probability model
				;;
		pumba_netem_rate)
				./tests/pumba_netem_rate.sh $container_name-pumba & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker netem_rate test:\\n"			
				#Rate limit egress traffic for specified containers
				;;
	esac
	shift
done

#Wait for tests
sleep $build_wait_time && echo -en "Done\\n"

docker_results() {
#Remove top line "HERE!!!"
sed -i '1d' ./results/pumba_results.log
#Remove empty commands
sed -i -e "/Kill containers/d" ./results/pumba_results.log

if [ -s ./results/pumba_results.log ]
	then
		echo -en "Test injected sucessfully\\n"
	else
		echo -en "Test injection failed\\n"
fi
}
#docker_results

#Confirm clean enviornment
#Using Docker instead of Pumba
./docker_nuke.sh

exit 0
