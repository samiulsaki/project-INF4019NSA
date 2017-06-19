#!/bin/bash
clear
docker ps
docker service ls

printf "\nDocker Machines\n"
docker-machine ls

printf "\nDocker Nodes\n"
docker node ls

printf "\nDocker Stack Services\n"
docker stack services monitor

printf "\nDocker PS - Swarm-Manager\n"
docker-machine ssh swarm-manager sudo docker ps

printf "\nDocker PS - Swarm-Worker1\n"
docker-machine ssh swarm-worker1 sudo docker ps

printf "\nDocker PS - Swarm-Worker2\n"
docker-machine ssh swarm-worker2 sudo docker ps


