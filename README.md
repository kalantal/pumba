# Pumba: Chaos testing tool for Docker

## About

Pumba is inspired by highly popular Netfix Chaos Monkey resilience testing tool for AWS cloud. Pumba takes a similar approach, but applies it to container level. It connects to the Docker daemon running on some machine (local or remote) and brings some level of chaos to it: “randomly” killing, stopping and removing running containers.

If your system is designed to be resilient, it should be able to recover from such failures. “Failed” services should be restarted and lost connections should be recovered. This is not as trivial as it sounds. You need to design your services differently. Be aware that a service can fail (for whatever reason) or service it depends on can disappear at any point of time (but can reappear later). Expect the unexpected!

## Strategy

1) The purpose of this module is to inject fault events to existing containers.
2) Monitoring of the chaos and faults injected is the responsibility of this module.
3) Monitoring of the container/tests being tested against -- is the responsibility of the container/test owner.

## Guidance

1) Start by defining ‘steady state’ as some measurable output of a system that indicates normal behavior.
2) Hypothesize that this steady state will continue in both the control group and the experimental group.
3) Introduce variables that reflect real world events like servers that crash, hard drives that malfunction, network connections that are severed, etc.
4) Try to disprove the hypothesis by looking for a difference in steady state between the control group and the experimental group.

The harder it is to disrupt the steady state, the more confidence we have in the behavior of the system.  If a weakness is uncovered, we now have a target for improvement before that behavior manifests in the system at large.

## Automated Usage

**pumba_kill**
```./pumba_chaos.sh rhel7 60 pumba_kill```

Send termination signal to the main process inside target container(s)

**pumba_delay**
```./pumba_chaos.sh rhel7 60 pumba_delay```

Delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation

**pumba_pause**
```./pumba_chaos.sh rhel7 60 pumba_pause```

Stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period

**pumba_stop**
```./pumba_chaos.sh rhel7 60 pumba_stop```

Remove target containers, with links and volumes

**pumba_rm**
```./pumba_chaos.sh rhel7 60 pumba_rm```

Pause all running processes within target containers

**pumba_netem_loss**
```./pumba_chaos.sh rhel7 60 pumba_netem_rate```

Adds packet losses, based on independent (Bernoulli) probability model

**pumba_netem_rate**
```./pumba_chaos.sh rhel7 60 pumba_netem_loss```

Rate limit egress traffic for specified containers

## Adding Tests

Add .sh file with the same schema as the others in the /tests/ folder.

Add new case --
```pumba_NEW_CASE)
	./tests/pumba_NEW_CASE.sh &>./results/pumba_results.log & ./tools/kill_script.sh $build_wait_time &
	echo -en "Pumba NEW_CASE test:\\n"			
	#NEW_CASE
	;;
```

## Manual Usage

You can download Pumba binary for your OS from [release](https://github.com/gaia-adm/pumba/releases) page.

```
$ pumba help

Pumba version [VERSION](./blob/master/VERSION)
NAME:
   Pumba - Pumba is a resilience testing tool, that helps applications tolerate random Docker container failures: process, network and performance.

USAGE:
   pumba [global options] command [command options] containers (name, list of names, RE2 regex)

VERSION:
   [VERSION](./blob/master/VERSION) - `git rev-parse HEAD --short` and `build time`

COMMANDS:
     kill     kill specified containers
     netem    emulate the properties of wide area networks
     pause    pause all processes
     stop     stop containers
     rm       remove containers
     help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --host value, -H value      daemon socket to connect to (default: "unix:///var/run/docker.sock") [$DOCKER_HOST]
   --tls                       use TLS; implied by --tlsverify
   --tlsverify                 use TLS and verify the remote [$DOCKER_TLS_VERIFY]
   --tlscacert value           trust certs signed only by this CA (default: "/etc/ssl/docker/ca.pem")
   --tlscert value             client certificate for TLS authentication (default: "/etc/ssl/docker/cert.pem")
   --tlskey value              client key for TLS authentication (default: "/etc/ssl/docker/key.pem")
   --debug                     enable debug mode with verbose logging
   --json                      produce log in JSON format: Logstash and Splunk friendly
   --slackhook value           web hook url; send Pumba log events to Slack
   --slackchannel value        Slack channel (default #pumba) (default: "#pumba")
   --interval value, -i value  recurrent interval for chaos command; use with optional unit suffix: 'ms/s/m/h'
   --random, -r                randomly select single matching container from list of target containers
   --dry                       dry runl does not create chaos, only logs planned chaos commands
   --help, -h                  show help
   --version, -v               print the version
```

### Kill Container command

```
$ pumba kill -h

NAME:
   pumba kill - kill specified containers

USAGE:
   pumba kill [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   send termination signal to the main process inside target container(s)

OPTIONS:
   --signal value, -s value  termination signal, that will be sent by Pumba to the main process inside target container(s) (default: "SIGKILL")
```

### Pause Container command

```
$ pumba pause -h

NAME:
   pumba pause - pause all processes

USAGE:
   pumba pause [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   pause all running processes within target containers

OPTIONS:
   --duration value, -d value  pause duration: should be smaller than recurrent interval; use with optional unit suffix: 'ms/s/m/h'
```

### Stop Container command

```
$ pumba stop -h
NAME:
   pumba stop - stop containers

USAGE:
   pumba stop [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   stop the main process inside target containers, sending  SIGTERM, and then SIGKILL after a grace period

OPTIONS:
   --time value, -t value  seconds to wait for stop before killing container (default 10) (default: 10)
```

### Remove (rm) Container command

```
$ pumba rm -h

NAME:
   pumba rm - remove containers

USAGE:
   pumba rm [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   remove target containers, with links and voluems

OPTIONS:
   --force, -f    force the removal of a running container (with SIGKILL, default: true)
   --links, -l    remove container links (default: false)
   --volumes, -v  remove volumes associated with the container (default: true)
```

### Network Emulation (netem) command

```
$ pumba netem -h

NAME:
   Pumba netem - delay, loss, duplicate and re-order (run 'netem') packets, to emulate different network problems

USAGE:
   Pumba netem command [command options] [arguments...]

COMMANDS:
     delay      delay egress traffic
     loss
     duplicate
     corrupt
     rate       limit egress traffic

OPTIONS:
   --duration value, -d value   network emulation duration; should be smaller than recurrent interval; use with optional unit suffix: 'ms/s/m/h'
   --interface value, -i value  network interface to apply delay on (default: "eth0")
   --target value, -t value     target IP filter; netem will impact only on traffic to target IP
   --tc-image value             Docker image with tc (iproute2 package); try 'gaiadocker/iproute2'
   --help, -h                   show help
```

#### Network Emulation Delay sub-command

```
$ pumba netem delay -h

NAME:
   Pumba netem delay - delay egress traffic

USAGE:
   Pumba netem delay [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   delay egress traffic for specified containers; networks show variability so it is possible to add random variation; delay variation isn't purely random, so to emulate that there is a correlation

OPTIONS:
   --time value, -t value          delay time; in milliseconds (default: 100)
   --jitter value, -j value        random delay variation (jitter); in milliseconds; example: 100ms ± 10ms (default: 10)
   --correlation value, -c value   delay correlation; in percentage (default: 20)
   --distribution value, -d value  delay distribution, can be one of {<empty> | uniform | normal | pareto |  paretonormal}
```

#### Network Emulation Loss sub-commands

```
$ pumba netem loss -h

NAME:
   Pumba netem loss - adds packet losses

USAGE:
   Pumba netem loss [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   adds packet losses, based on independent (Bernoulli) probability model
   see:  http://www.voiptroubleshooter.com/indepth/burstloss.html

OPTIONS:
   --percent value, -p value      packet loss percentage (default: 0)
   --correlation value, -c value  loss correlation; in percentage (default: 0)
```

```
$ pumba netem loss-state -h

NAME:
   Pumba netem loss-state - adds packet losses, based on 4-state Markov probability model

USAGE:
   Pumba netem loss-state [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   adds a packet losses, based on 4-state Markov probability model
     state (1) – packet received successfully
     state (2) – packet received within a burst
     state (3) – packet lost within a burst
     state (4) – isolated packet lost within a gap
   see: http://www.voiptroubleshooter.com/indepth/burstloss.html

OPTIONS:
   --p13 value  probability to go from state (1) to state (3) (default: 0)
   --p31 value  probability to go from state (3) to state (1) (default: 100)
   --p32 value  probability to go from state (3) to state (2) (default: 0)
   --p23 value  probability to go from state (2) to state (3) (default: 100)
   --p14 value  probability to go from state (1) to state (4) (default: 0)
```

```
$ pumba netem loss-gemodel -h

NAME:
   Pumba netem loss-gemodel - adds packet losses, according to the Gilbert-Elliot loss model

USAGE:
   Pumba netem loss-gemodel [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   adds packet losses, according to the Gilbert-Elliot loss model
   see: http://www.voiptroubleshooter.com/indepth/burstloss.html

OPTIONS:
   --pg value, -p value  transition probability into the bad state (default: 0)
   --pb value, -r value  transition probability into the good state (default: 100)
   --one-h value         loss probability in the bad state (default: 100)
   --one-k value         loss probability in the good state (default: 0)
```

```
$ pumba netem rate -h

NAME:
   Pumba netem rate - rate limit egress traffic

USAGE:
   Pumba netem rate [command options] containers (name, list of names, RE2 regex)

DESCRIPTION:
   rate limit egress traffic for specified containers

OPTIONS:
   --rate value, -r value            delay outgoing packets; in common units (default: "100kbit")
   --packetoverhead value, -p value  per packet overhead; in bytes (default: 0)
   --cellsize value, -s value        cell size of the simulated link layer scheme (default: 0)
   --celloverhead value, -c value    per cell overhead; in bytes (default: 0)
```

##### Examples

```
# add 3 seconds delay for all outgoing packets on device `eth0` (default) of `mydb` Docker container for 5 minutes

$ pumba netem --duration 5m delay --time 3000 mydb
```

```
# add a delay of 3000ms ± 30ms, with the next random element depending 20% on the last one,
# for all outgoing packets on device `eth1` of all Docker container, with name start with `hp`
# for 10 minutes

$ pumba netem --duration 5m --interface eth1 delay \
      --time 3000 \
      --jitter 30 \
      --correlation 20 \
    re2:^hp
```

```
# add a delay of 3000ms ± 40ms, where variation in delay is described by `normal` distribution,
# for all outgoing packets on device `eth0` of randomly chosen Docker container from the list
# for 10 minutes

$ pumba --random netem --duration 5m \
    delay \
      --time 3000 \
      --jitter 40 \
      --distribution normal \
    container1 container2 container3
```

##### `tc` tool
Pumba uses `tc` Linux tool for network emulation. You have two options:

1. Make sure that container, you want to disturb, has `tc` tool available and properly installed (install `iproute2` package)
2. Use `--tc-image` option, with any `netem` command, to specify external Docker image with `tc` tool available. Pumba will create a new container from this image, adding `NET_ADMIN` capability to it and reusing target container network stack. You can try to use [gaiadocker/iproute2](https://hub.docker.com/r/gaiadocker/iproute2/) image (it's just Alpine Linux 3.3 with `iproute2` package installed)

**Note:** For Alpine Linux based image, you need to install `iproute2` package and also to create a symlink pointing to distribution files `ln -s /usr/lib/tc /lib/tc`.

## Used Libraries and Code

- Official Docker API for Go [docker/docker](https://github.com/docker/docker)
- Logging  [Sirupsen/logrus](https://github.com/Sirupsen/logrus)
- Command line app lib [codegangsta/cli](https://github.com/codegangsta/cli)

I've also borrowed some code from very good [CenturyLinkLabs/watchtower](https://github.com/CenturyLinkLabs/watchtower) project.

## License

Code is under the [Apache License v2](https://www.apache.org/licenses/LICENSE-2.0.txt).
