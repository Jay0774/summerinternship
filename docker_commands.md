# COMMAND SHEET OF DOCKER
------------------------------------------------------------------------------
## Container run
docker create: creates a writable container layer over the specified image and prepares it for running the specified command. The container ID is then printed to STDOUT. This is similar to docker run -d except the container is never started. We can then use the docker start <container_id> command to start the container at any point.
$ docker create -t -i fedora bash
...
dff32a272ad4c94cd51419ee4f53c371e3c3a8cfb448a469634d4420e139d118

$ docker start -a -i dff32a272ad4c
[root@dff32a272ad4 /]# 
i: interactive, keep STDIN open even if not attached
t: Allocate a pseudo-TTY
a: Attach container's STDOUT and STDERR and forward all signals to the process.

docker rename allows the container to be renamed.
$ docker rename my_container my_new_container

docker run creates and starts a container in one operation.
$ docker run -it ubuntu-ssh-k /bin/bash

docker rm deletes a container.
$ docker rm myfedora

docker update updates a container's resource limits. Example : updating multiple resource configurations for multiple containers:
$ docker update --cpu-shares 512 -m 300M dff32a272ad4 happy_kare
dff32a272ad4
happy_kare

------------------------------------------------------------------------------

## Container info
docker ps shows running containers.
$ docker ps 
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS              PORTS               NAMES
e2481c1bad5d        ubuntu-ssh-k:latest   "/bin/bash"         10 hours ago        Up 10 hours                             hopeful_carson 

docker logs gets logs from container. (We can use a custom log driver, but logs is only available for json-file and journald in 1.10)
$ docker logs 839f66a78983

docker inspect looks at all the info on a container (including IP address).
To get an IP address of a running container:
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -q)
172.17.0.5

docker events gets events from container.
docker port shows public facing port of container.
docker top shows running processes in container.
docker stats shows containers' resource usage statistics.
docker diff shows changed files in the container's FS.


------------------------------------------------------------------------------


## Container start/stop

docker start starts a container so it is running.
docker stop stops a running container.
docker restart stops and starts a container.
docker pause pauses a running container, "freezing" it in place.
docker unpause will unpause a running container.
docker wait blocks until running container stops.
docker kill sends a SIGKILL to a running container.
docker attach will connect to a running container.
Or we can use the following to get tty:
$ docker exec -i -t my-nginx-1 /bin/bash

Note that we used exec to run a command in a "running" container!



------------------------------------------------------------------------------


 
## Image create/remove

docker images : shows all images.
docker import : creates an image from a tarball.
docker build : creates image from Dockerfile.
docker commit : creates image from a container, by default, the container being committed and its processes will be paused while the image is committed. This reduces the likelihood of encountering data corruption during the process of creating the commit. As an example, let's install nginx to the ubuntu container:
$ docker run -it ubuntu /bin/bash
root@bf5d24821dfa:/# apt-get update
root@bf5d24821dfa:/# apt-get install nginx

While the container is running, on another terminal, we can commit the change to another image:

$ docker ps
CONTAINER ID        IMAGE               COMMAND             
bf5d24821dfa        ubuntu              "/bin/bash"  

$ docker commit bf5d24821dfa ubuntu-nginx

$ docker images
REPOSITORY       TAG                 IMAGE ID            
ubuntu-nginx     latest              91cc8b745f5e 

$ docker run -it ubuntu-nginx
root@9644a814e95a:/#

$ docker ps
CONTAINER ID        IMAGE               COMMAND            
9644a814e95a        ubuntu-nginx        "/bin/bash"       
bf5d24821dfa        ubuntu              "/bin/bash"       

Note the the new container dit not start "nginx" server. So, we can commit a container with new CMD and EXPOSE instructions:

root@9644a814e95a:/# exit

$ docker commit -m 'added nginx start' --change='CMD ["nginx", "-g daemon off;"]' -c "EXPOSE 80" 9644a814e95a ubuntu-nginx:version2


-m 'added nginx start' creates a comment for this commit.
--change='CMD ... is changing the CMD command, which is what the image will run when it is first started up. In this example, we are telling the image to run nginx in the foreground. Most base os images have CMD set to bash so we can interact with the os when attaching.
We used "EXPOSE" to get the port exposed to the host.
"9644a814e95a" is the name of the container we want to commit from.
"ubuntu-nginx:version2" is our name for the new image. We appended version to the name of the container.

We can now view our new image with the following command:

$ docker images
REPOSITORY         TAG                 IMAGE ID            
ubuntu-nginx       version2            61918a284221

Run the new image:

$ docker run -idt ubuntu-nginx:version2

$ ps aux | grep -v grep |grep nginx
root     12546  0.0  0.2 124972  9560 pts/25   Ss+  10:21   0:00 nginx: master process nginx -g daemon off;
www-data 12565  0.0  0.0 125332  3040 pts/25   S+   10:21   0:00 nginx: worker process
www-data 12566  0.0  0.0 125332  3040 pts/25   S+   10:21   0:00 nginx: worker process

$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -q)
172.17.0.2

We can see the index page:

nginx-page-expost-commit-demo-off.png
docker rmi : removes an image
docker load : loads an image from a tar archive as STDIN, including images and tags
.
docker save : saves an image to a tar archive stream to STDOUT with all parent layers, tags & versions
.



------------------------------------------------------------------------------


 
## Container info
Getting Docker Container's IP Address from host machine:

$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -q)
172.17.0.2
172.17.0.3


------------------------------------------------------------------------------

 
## Image info
docker history shows history of image.
docker tag tags an image to a name (local or registry).

------------------------------------------------------------------------------

## Network create/remove/info/connection
docker network create
docker network rm
docker network ls
docker network inspect
docker network connect
docker network disconnect



------------------------------------------------------------------------------


 
## Docker Repo
docker login to login to a registry. (see docker push)
$ docker login --username=dockerbogo
Password: 
Login Succeeded

docker logout to logout from a registry.
$ docker logout
Removing login credentials for https://index.docker.io/v1/

docker search searches registry for image.
$ docker search mysql
NAME                       DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
mysql                      MySQL is a widely used, open-source relati...   2797      [OK]       
mysql/mysql-server         Optimized MySQL Server Docker images. Crea...   182                  [OK]
...

docker pull pulls an image from registry to local machine.
$ docker pull ubuntu
latest: Pulling from ubuntu
20ee58809289: Pull complete 
f905badeb558: Pull complete 
119df6bf2a3a: Pull complete 
94d6eea646bc: Pull complete 
bb4eabee84bf: Pull complete 
Digest: sha256:85af8b61adffea165e84e47e0034923ec237754a208501fce5dbeecbb197062c
Status: Downloaded newer image for ubuntu:latest
Docker images can consist of multiple layers. In the example above, the image consists of five layers.


docker push pushes an image to the registry from local machine. First, we'll install nginx on top of ubuntu, and then commit it. After login to DockerHub, we'll tag the image and push it:
$ docker run -it ubuntu:latest /bin/bash

root@846346c3482f:/# apt-get update
root@846346c3482f:/# apt-get install nginx

$ docker commit 846346c3482f ubuntu-with-nginx

$ docker images
REPOSITORY           TAG      IMAGE ID        CREATED         SIZE
ubuntu-with-nginx    latest   de412f7faba5   16 minutes ago  212 MB

$ docker login --username=dockerbogo
Password: 
Login Succeeded

$ docker tag de412f7faba5 dockerbogo/ubuntu-with-nginx:myfirstpush

$ docker push dockerbogo/ubuntu-with-nginx:myfirstpush
The push refers to a repository [docker.io/dockerbogo/ubuntu-with-nginx]
44f391d61c42: Pushed 
73e5d2de6e3e: Mounted from library/ubuntu 
08f405d988e4: Mounted from library/ubuntu 
511ddc11cf68: Mounted from library/ubuntu 
a1a54d352248: Mounted from library/ubuntu 
9d3227c1793b: Mounted from library/ubuntu 
myfirstpush: digest: sha256:a24d914b8e3a013987314054b2c2409e99c00384342b25ee7dba4c51cb1ea49a size: 1569

We can check if the push was successful:
