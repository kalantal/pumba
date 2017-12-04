#!/bin/bash
#set -x

#Do not edit
export pumba_test=./pumba_linux_386
export build_wait_time=60
export test_wait_time=60

sudo groupadd docker
sudo gpasswd -a $USER docker

#Your modifications here
export container_name=$1

export pumba_kill="timeout $test_wait_time ./tests/pumba_kill.sh"
export pumba_delay="timeout $test_wait_time ./tests/pumba_delay.sh"
export pumba_pause="timeout $test_wait_time ./tests/pumba_pause.sh"
export pumba_stop="timeout $test_wait_time ./tests/pumba_stop.sh"
export pumba_rm="timeout $test_wait_time ./tests/pumba_rm.sh"
export pumba_netem_loss="timeout $test_wait_time ./tests/pumba_netem_loss.sh"
export pumba_netem_rate="timeout $test_wait_time ./tests/pumba_netem_rate.sh"

#Validate paramaters
if [[ $# -eq 0 ]] ; then
  echo -en "No argeuments supplied. You must specify which container to use and which test to run\\n"
  echo -en "ex: ./pumba_master.sh ubuntu test_1"
  exit 0
fi

#Build the enviornment
docker_build_containers() {
#x4 containers
echo -en "Building containers [$1]:\\n"
for i in {1..4}; do docker run -d --rm --name test$i $container_name tail -f /dev/null; done
}
docker_build_containers

echo -en "Pausing for [$build_wait_time] seconds to allow containers to spin up and tests to start.\\n"
sleep $build_wait_time

###
###MONITOR &>>./log
###

while [ $# -gt 0 ]; do
	shift #this preserves the first argument $1 as the $container_name
	case "$1" in
	pumba_kill)
			$pumba_kill
			echo -en "Docker kill test.\\n"
			#Send termination signal to the main process inside target container(s)
			;;
	pumba_delay)
			$pumba_delay
			echo -en "Docker delay test.\\n"			
			#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
			;;
	pumba_pause)
			$pumba_pause
			echo -en "Docker pause test.\\n"
			#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period
			;;
	pumba_stop)
			$pumba_stop
			echo -en "Docker stop test.\\n"			
			#Remove target containers, with links and volumes
			;;
	pumba_rm)
			$pumba_rm
			echo -en "Docker rm test.\\n"			
			#Pause all running processes within target containers
			;;
	pumba_netem_loss)
			$pumba_netem_loss
			echo -en "Docker netem_loss test.\\n"
			#Adds packet losses, based on independent (Bernoulli) probability model
			;;
	pumba_netem_rate)
			$pumba_netem_rate
			echo -en "Docker netem_rate test.\\n"			
			#Rate limit egress traffic for specified containers
			;;
	esac
	shift
done

#Confirm clean enviornment
#Using Docker instead of Pumba
docker_clean() {
docker ps -a >/tmp/docker_ps
#sed -i '1d' /tmp/docker_ps

if grep -q "test" /tmp/docker_ps; 
	then
		echo -en "Containers stopped:\\n"
		docker stop $(docker ps -a -q)
	else
		echo -en "No Containers to stop.\\n"
fi

}
docker_clean

echo -en "Done.\\n"

exit 0
