#!/bin/bash
#set -x

export container_name=$1
export build_wait_time=60
#export test_wait_time=60

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
if [ -z "$*" ] ; then
  echo -en "No argeuments supplied. You must specify which container to use and which test to run\\n"
  echo -en "ex: ./pumba_master.sh ubuntu test_1\\n"
  exit 0
fi

#Build the enviornment
docker_build_containers() {
#x4 containers
echo -en "Building containers for [$container_name]:\\n"
#docker run -d --rm --name $container_name "$container_name" tail -f /dev/null; done
#for i in {1..4}; do docker run -d --rm --name test$i ubuntu tail -f /dev/null; done
for i in {1..4}; do docker run -d --rm --name test$i "$container_name" tail -f /dev/null; done
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
				./tests/pumba_kill.sh &>>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker kill test:\\n"
				#Send termination signal to the main process inside target container(s)
				;;
		pumba_delay)
				./tests/pumba_delay.sh &>>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker delay test:\\n"			
				#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
				;;
		pumba_pause)
				./tests/pumba_pause.sh &>>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker pause test:\\n"
				#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period
				;;
		pumba_stop)
				./tests/pumba_stop.sh &>>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker stop test:\\n"			
				#Remove target containers, with links and volumes
				;;
		pumba_rm)
				./tests/pumba_rm.sh &>>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker rm test:\\n"			
				#Pause all running processes within target containers
				;;
		pumba_netem_loss)
				./tests/pumba_netem_loss.sh &>>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker netem_loss test:\\n"
				#Adds packet losses, based on independent (Bernoulli) probability model
				;;
		pumba_netem_rate)
				./tests/pumba_netem_rate.sh &>>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
				echo -en "Docker netem_rate test:\\n"			
				#Rate limit egress traffic for specified containers
				;;
	esac
	shift
done

#Wait for tests
sleep $build_wait_time && echo -en "Done\\n"

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
		echo -en "No containers left over to stop\\n"
fi
}
docker_clean

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

exit 0
