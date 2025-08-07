#!/bin/bash

set -e

# install selkies build dependencies
apt update
apt install --no-install-recommends -y $(cat /lists/selkies.list)
