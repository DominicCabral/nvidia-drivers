apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get remove -y nvidia*
apt-get autoremove -y
apt-get install -y dkms build-essential linux-headers-generic

cat <<EOF >/etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
update-initramfs -u

wget https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda-repo-ubuntu1604-8-0-local_8.0.44-1_amd64-deb --no-check-certificate
dpkg -i cuda-repo-ubuntu1604-8-0-local_8.0.44-1_amd64-deb
apt-get update
apt-get install -y cuda
apt-get update --fix-missing -y
apt-get install -y cuda

cat <<EOF >/etc/ld.so.conf.d/cuda-lib64.conf
/usr/local/cuda/lib64
EOF

sudo ldconfig

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce

# Install nvidia-docker and nvidia-docker-plugin
wget --no-check-certificate -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
