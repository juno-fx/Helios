set -e

# build dependencies
apt-get update
apt-get install -y \
  gnupg
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
echo 'deb https://deb.nodesource.com/node_20.x noble main' > /etc/apt/sources.list.d/nodesource.list && \
apt-get update
apt-get install -y \
  g++ \
  gcc \
  libpam0g-dev \
  libpulse-dev \
  make \
  nodejs
