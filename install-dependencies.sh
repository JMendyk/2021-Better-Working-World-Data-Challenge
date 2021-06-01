#!/bin/bash

if [ $# -lt 1 ]; then
  cat <<EOS
Usage:
  ./install-dependencies.sh PASSWORD

Arguments:
  PASSWORD    # Password to set for Jupyter login
EOS
exit 1
fi

# Capture a password
PASSWORD="${1}"

# Do it different if it's local Docker
LOCAL="${2}"

set -ex
# Log start time
echo "Started $(date)"
readlink -f $0

function try() {
  for i in $(seq 10); do
    $* && break
    sleep 10
  done
}

if ! [[ $LOCAL = "true" ]]; then

    export DEBIAN_FRONTEND=noninteractive
    try 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg' > docker.gpg
    try apt-get update
    apt-key add docker.gpg 
    apt-key list
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    try apt-get update 
    try apt-get install -y docker-ce python3-pip unzip wget
    try pip3 install --upgrade pip
    try pip3 install docker-compose

    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    try curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
    try curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
    
    # try curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add -
    # distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    # try curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list
    try apt-get update
    try apt-get install -y nvidia-docker2 # nvidia-container-runtime nvidia-container-toolkit
    try systemctl restart docker

    # Get our code
    url=https://codeload.github.com/JMendyk/2021-Better-Working-World-Data-Challenge/zip/main
    try wget $url -O /tmp/archive.zip 
    unzip /tmp/archive.zip
    mv 2021-Better-Working-World-Data-Challenge-main /opt/odc

    # We need to change some local vars.
    sed --in-place "s/secretpassword/${PASSWORD}/g" /opt/odc/docker-compose.yml

    # We need write access in these places
    chmod -R 777 /opt/odc/notebooks
    cd /opt/odc

    # Start the machines
    docker-compose build
    docker-compose up -d

    # Wait for them to wake up
    sleep 20
fi

# wget -O /root/install-cube.sh https://raw.githubusercontent.com/JMendyk/2021-Better-Working-World-Data-Challenge/main/install-cube.sh
# chmod +x /root/install-cube.sh

# echo "./install-cube.sh ${PASSWORD} 2>&1 | tee -a /var/log/install-cube.log" >> /root/.login

# # Reboot is required for GPU-dependent containers to work
# reboot


# Initialise and load a product, and then some data
# Note to future self, we can't use make here because of TTY interactivity (the -T flag)
# Initialise the datacube DB
try docker-compose exec -T jupyter datacube -v system init
# Add some custom metadata
docker-compose exec -T jupyter datacube metadata add /scripts/data/metadata.eo_plus.yaml
docker-compose exec -T jupyter datacube metadata add /scripts/data/eo3_landsat_ard.odc-type.yaml
# And add some product definitions
docker-compose exec -T jupyter datacube product add /scripts/data/ga_s2a_ard_nbar_granule.odc-product.yaml
docker-compose exec -T jupyter datacube product add /scripts/data/ga_s2b_ard_nbar_granule.odc-product.yaml
docker-compose exec -T jupyter datacube product add /scripts/data/ga_ls7e_ard_3.odc-product.yaml
docker-compose exec -T jupyter datacube product add /scripts/data/ga_ls8c_ard_3.odc-product.yaml
docker-compose exec -T jupyter datacube product add /scripts/data/linescan.odc-product.yaml
docker-compose exec -T jupyter datacube product add /scripts/data/esa_s1_rtc.odc-product.yaml
# Now index some datasets
docker-compose exec -T jupyter bash -c "dc-index-from-tar --protocol https --ignore-lineage -p ga_ls7e_ard_3 -p ga_ls8c_ard_3 /scripts/data/ls78.tar.gz"
docker-compose exec -T jupyter bash -c "dc-index-from-tar --protocol https --ignore-lineage -p ga_s2a_ard_nbar_granule -p ga_s2b_ard_nbar_granule /scripts/data/s2ab.tar.gz"
docker-compose exec -T jupyter bash -c "dc-index-from-tar --protocol https --ignore-lineage -p linescan /scripts/data/linescan.tar.gz"
docker-compose exec -T jupyter bash -c "dc-index-from-tar --protocol https --ignore-lineage --stac -p s1_rtc /scripts/data/sentinel-1.tar.gz"

echo "Finished $(date)"
