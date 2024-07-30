#!/bin/bash

DOCKER_COMPOSE_FILE="docker-compose.yml"
HOSTS_FILE="../hosts.yml"

echo "all:" > $HOSTS_FILE
echo "  hosts:" >> $HOSTS_FILE

yq eval '.services | keys[]' $DOCKER_COMPOSE_FILE | while read service; do
    container_name=$(yq eval ".services.$service.container_name" $DOCKER_COMPOSE_FILE)
    port=$(yq eval ".services.$service.ports[0]" $DOCKER_COMPOSE_FILE | cut -d ':' -f 1)
    ssh_username=$(yq eval ".services.$service.environment[] | select(. == \"SSH_USERNAME*\" )" $DOCKER_COMPOSE_FILE | cut -d '=' -f 2)
    password=$(yq eval ".services.$service.environment[] | select(. == \"PASSWORD*\" )" $DOCKER_COMPOSE_FILE | cut -d '=' -f 2)

    echo "    $container_name:" >> $HOSTS_FILE
    echo "      ansible_host: localhost" >> $HOSTS_FILE
    echo "      ansible_port: $port" >> $HOSTS_FILE
    echo "      ansible_user: $ssh_username" >> $HOSTS_FILE
    echo "      ansible_become_password: $password" >> $HOSTS_FILE
    echo "      ansible_ssh_private_key_file: ~/.ssh/id_rsa" >> $HOSTS_FILE
    echo  >> $HOSTS_FILE
done