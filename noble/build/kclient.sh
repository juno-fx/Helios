set -e

# build dependencies
apt-get update
apt-get install -y \
  gnupg
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get update
apt-get install -y \
  g++ \
  gcc \
  libpam0g-dev \
  libpulse-dev \
  make \
  nodejs
