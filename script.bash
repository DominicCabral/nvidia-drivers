apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get remove -y nvidia*
apt-get autoremove -y

wget https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda-repo-ubuntu1604-8-0-local_8.0.44-1_amd64-deb --no-check-certificate
sudo dpkg -i cuda-repo-ubuntu1604-8-0-local_8.0.44-1_amd64-deb
apt-get install -y cuda
apt-get update --fix-missing -y
apt-get install -y cuda