# Ceph application with Docker-Compose

## Inception
Why doing Ceph on Docker ?

Especially as Ceph is clearly not designed to be run in a containerized environment due to its dependance on the IP topology. The monitors and other datastores have their IP hardcoded in the Ceph cluster definition. In Docker, upon every restart the containers will have a new IP adress so breaking the Ceph cluster topology map. 

That said, Ceph provides a distributed data store which can ensure data persistence across multiple nodes. In a containerized VDI environment, where user data must be preserved, Ceph will provide the backend functions to ensure persistence across desktops, reboots...

The idea here is quite simple : use <ref>this</ref> containerized environment,  add ownCloud to provide file persistence and back ownCloud with a Ceph cluster. 

This tutorial is really the first version to prove the approach is viable. Many issues remain though but it should provide a distributed filesystem on which ownCloud can rely.

##Quickstart
Pre-requisites (not tested with lower versions):
     * Docker 1.8.0+ to host Ceph environment
     * Docker-compose 1.8.0+ (?) to build the Environment 
     * Ceph-common to mount the Ceph partition on Docker host

I tried to use Boot2docker & Photon as Docker host but there is no ceph-common package available to mount on the host. So you can still build on those hosts but won't be able to mount the CephFS drive.

* Step 1 : Clone the repo : git clone https://github.com/besn0847/ceph-app.git
* Step 2 : Build the images : cd ceph-app && docker-compose -f common.yml build
* Step 3 : Bootstrap the environment : docker-compose up -d

Again don't start and stop the containers as their IP will change and it will screw the Ceph topology.

## Architecture
The overall architecture is quite simple :

	* 1 container to provide DNS services
	* 1 container acting as the Ceph management node
	* 1 container acting as the Ceph monitor
	* 2 containers acting as the Ceph object storage daemons
	* 1 container acting as the Ceph meta data controller

The DNS container is used to provide name resolution to other containers as the Docker linking capability is limited to downstream links aka. not possible to link a container to another which as not been yet created.

Each container hosts an SSH server except the DNS one which only provide DNS capability. The default login is 'ceph/passw0rd' on each host with port exposed on the management one only.

## Operations
As said previouly, it is not possible to stop and restart containers for now due to Ceph dependency on IP topology and Docker resetting IP addresses on each reboot. 
So the Ceph app can only be started once.

### - App bootstrap & start-up
First and foremost, you need to download the app topo builder from Github :

     git clone https://github.com/besn0847/ceph-app.git

Then you need to build the container images

     cd ceph-app && docker-compose -f common.yml build

Once the images have been built (take 15 minutes depending on your network speed), just kick off the app:

     docker-compose up -d

The DNS registrations and the cluster configuration must be ordered properly. So i introduced few timers meaning the average bootstrap time is around 30 to 40 seconds, so just wait about one minute before checking the deployment is OK.

To check the Ceph deployment, connect to the mgmt node :

     ssh -p <ssh_exposed_port> ceph@localhost

Then connect to the monitor and start the Ceph command line :
     
     `ssh mon0
     sudo ceph`

And finally check the cluster health :

	ceph> health
		HEALTH_OK
	ceph> status
		cluster a7f64266-0894-4f1e-a635-d0aeaca0e993
		health HEALTH_OK
		monmap e1: 1 mons at {mon0=172.17.0.26:6789/0}, election epoch 2, quorum 0 mon0
		mdsmap e15: 1/1/1 up {0=0=up:active}
		osdmap e14: 2 osds: 2 up, 2 in
		pgmap v25: 192 pgs, 3 pools, 1884 bytes data, 20 objects
			7483 MB used, 27788 MB / 37206 MB avail
			192 active+clean
	ceph> quit

### - App  ops
You can also mount the CephFS drive on the Docker host provided you have the ceph-common package installed.
To do so, go back to the management node :
     ssh -p <ssh_exposed_port> ceph@localhost

Cat the install file :
     sudo cat /var/log/supervisor/ceph-deploy-stdout---supervisor-<some_letters>.log

Right at the end you have the secret key :
     sudo grep "secret=" /var/log/supervisor/ceph-deploy-stdout---supervisor-iEaBlQ.log
          sudo mount -t ceph mon0:6789:/ <your_mount_point> -o name=admin,secret=AQDpqQpWqMqjFhAAwVxOT2gvrakkY2GTTEe+yg==

Get the monitor IP address
     nslookup mon0
          Server:         172.17.0.1
          Address:        172.17.0.1#53
     
          Name:   mon0.int.docker.net
          Address: 172.17.0.2

Go back to the Docker host and mount the CephFS drive :
     sudo mount -t ceph 172.17.0.2:6789:/ /mnt -o name=admin,secret=AQDpqQpWqMqjFhAAwVxOT2gvrakkY2GTTEe+yg==

Just check the drive is mounted a 'df -k' command.

Your basic Ceph cluster is ready in less than 1 minute !

## References
     Previous post on Ceph with Docker plumbing : here
     Advanced Ceph deployment tutorial : here

## Issues
     #1 When restarting the containers, their IPaddresses get changed which destroys the Ceph cluster topology
               Workaround : none - just use this to quickly have a clean Ceph cluster for test & dev
     
     #2 The 6789 port is exposed on the monitor but it is not possible to mount the CephFS drive
               Workaround : do the mount directly on the mon0 IP address - an direct IP connectivity is required (no PAT)

## Future

	* VDI : i'll use this along with the containerized desktop to deliver a Docker VDI experience
	* Need to find a way to fix the issue #1 above
	* I'll probably add a RadosGW at some point to offer an S3-like mount point
	* I'll add an ownCloud container to store data on the Cepf FS
	* Clustering support with Swarm addition

     


     
