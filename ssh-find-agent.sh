#!/bin/sh -e
# Log the location of the SSH agent to a file

echo $SSH_AUTH_SOCK > /tmp/agent_socket_path
tail /dev/null
