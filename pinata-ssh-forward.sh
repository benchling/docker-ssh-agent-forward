#!/usr/bin/env bash

set -e

IMAGE_NAME=pinata-sshd
CONTAINER_NAME=pinata-sshd
LOCAL_STATE=~/.pinata-sshd
LOCAL_PORT=2244

AUTHKEYS=~/.ssh/authorized_keys
if [[ ! -f $AUTHKEYS ]]; then
  echo "Missing $AUTHKEYS"
  exit 1
fi

rm -rf ${LOCAL_STATE}
mkdir -p ${LOCAL_STATE}

docker rm --force ${CONTAINER_NAME} >/dev/null 2>&1 || true
docker run --name ${CONTAINER_NAME} \
  -v $AUTHKEYS:/root/.ssh/authorized_keys \
  -v ${LOCAL_STATE}:/tmp \
  -d -p ${LOCAL_PORT}:22 ${IMAGE_NAME} > /dev/null

IP=`docker inspect --format '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostIp }}' ${CONTAINER_NAME}`
ssh-keyscan -p ${LOCAL_PORT} ${IP} > ${LOCAL_STATE}/known_hosts 2>/dev/null

ssh -n -o "UserKnownHostsFile ${LOCAL_STATE}/known_hosts" -o 'PasswordAuthentication no' \
  -A -p ${LOCAL_PORT} root@${IP} /root/ssh-find-agent.sh &

echo 'Agent forwarding successfully started.'
echo 'Run "pinata-ssh-mount" to get a command-line fragment that'
echo 'can be added to "docker run" to mount the SSH agent socket.'
echo
echo 'For example:'
echo 'docker run -it `pinata-ssh-mount` ocaml/opam ssh git@github.com'
