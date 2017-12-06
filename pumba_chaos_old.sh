#!/bin/bash
#set -x

#Useage: ./pumba_master.sh [Container]

export container_name=$1
export build_wait_time=60

chmod +x ./*
chmod +x ./tests/*
chmod +x ./tools/*
chmod +x ./pumba_linux_386

#Validate paramaters
if (( $# < 1 )); then
	echo -en "Useage:\\n"
	echo -en "ex: ./pumba_master.sh rhel7 60 all\\n"
  exit 0
fi

docker_setup() {
#sudo groupadd docker
id -u "$USER" &>/dev/null || sudo groupadd docker0
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

echo > ./results/pumba_results.log

echo -en "Pausing for [$build_wait_time] seconds to allow containers to spin up and tests to start.\\n"
sleep "60"

./tests/pumba_kill.sh "$container_name"-pumba & ./tools/kill_script.sh "60" && sleep "60" &
echo -en "Docker kill test:\\n"
#Send termination signal to the main process inside target container(s)
sleep "60" && ./tools/kill_script.sh

./tests/pumba_delay.sh "$container_name"-pumba & ./tools/kill_script.sh "60" && sleep "60" &
echo -en "Docker delay test:\\n"
#Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation
sleep "60" && ./tools/kill_script.sh

./tests/pumba_pause.sh "$container_name"-pumba & ./tools/kill_script.sh "60" && sleep "60" &
echo -en "Docker pause test:\\n"
#Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period
sleep "60" && ./tools/kill_script.sh

./tests/pumba_stop.sh "$container_name"-pumba & ./tools/kill_script.sh "60" && sleep "60" &
echo -en "Docker stop test:\\n"
#Remove target containers, with links and volumes
sleep "60" && ./tools/kill_script.sh

./tests/pumba_rm.sh "$container_name"-pumba & ./tools/kill_script.sh "60" && sleep "60" &
echo -en "Docker rm test:\\n"
#Pause all running processes within target containers
sleep "60" && ./tools/kill_script.sh

./tests/pumba_netem_loss.sh "$container_name"-pumba & ./tools/kill_script.sh "60" && sleep "60" &
echo -en "Docker netem_loss test:\\n"
#Adds packet losses, based on independent (Bernoulli) probability model
sleep "60" && ./tools/kill_script.sh

./tests/pumba_netem_rate.sh "$container_name"-pumba & ./tools/kill_script.sh "60" && sleep "60" &
echo -en "Docker netem_rate test:\\n"
#Rate limit egress traffic for specified containers

#Wait for tests
sleep "60" && echo -en "Done\\n"

docker_results_cleanup() {
#Remove top line
#sed -i '1d' ./results/pumba_results.log

#Remove empty commands
sed -i -e "/HERE/d" ./results/pumba_results.log
sed -i -e "/Remove containers/d" ./results/pumba_results.log
sed -i -e "/Stop containers/d" ./results/pumba_results.log
sed -i -e "/Kill containers/d" ./results/pumba_results.log
sed -i -e "/Pause containers/d" ./results/pumba_results.log
sed -i -e "/netem: delay/d" ./results/pumba_results.log
sed -i -e "/netem: loss/d" ./results/pumba_results.log
sed -i -e "/netem: rate/d" ./results/pumba_results.log
}
docker_results_cleanup

pumba_validation() {
if grep "level=info" ./results/pumba_results.log > /dev/null
then
	echo -en "Test(s) injected sucessfully\\n"
else
	echo -en "Test(s) injection failed\\n"
fi
}
pumba_validation > ./results/complete.log

cat ./results/complete.log
cat ./results/pumba_results.log

#Confirm clean enviornment
#Using Docker instead of Pumba
./tools/docker_nuke.sh

exit 0
