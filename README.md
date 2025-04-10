# simple_slurm_cluster
Create a functional slurm cluster

# build dockerfile

First, check the release verson of SLURM on their git repo: https://github.com/SchedMD/slurm/releases
The release version will be used to build the version needed to test, e.g: slurm-24-11-2-1.

Don't forget to be part of docker group as user, e.g:

```console
$ id
uid=1000(marvin) gid=1000(marvin) groups=1000(marvin),999(docker)
```
Build the container:
```
$ podman build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg SLURM_VERSION=slurm-24-11-2-1 -t slurm:latest .
$ podman image ls
slurm        latest     79739f328ae7   3 hours ago      1GB
```
# setup cluster

Configure your slurm.conf and slurmdbd.conf as needed and store them into the directory config/slurm. Of course, you can manage the configuration as you wish, but you will have to adapt the docker-compose.yml file.

Launch a slurm network.
```console
$ podman network create slurm
```

Then, start the cluster:
```console
$ podman-compose up -d
Starting mariadb ... done
Starting slurm   ... done
Starting c1      ... done
```
# shell to one or another

In order to get access to one of the container, you will have to exec a bash into the one you like to shell, e.g:
```console
$ podman-compose exec slurm bash
[root@c1 /]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
short*       up   infinite      1  idle~ c1
lon g        up   infinite      0    n/a
[root@c1 /]#
```
# Quick example 

To ensure that slurm is working, you can run a quick job, e.g :
```console
[root@slurm /]# srun -N 2 hostname
c1
c2
```




