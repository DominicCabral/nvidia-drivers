#!/bin/bash -e

# # kubelet can't use the GPU without nvidia-uvm
# if sudo modprobe nvidia-uvm ; then
# 		sudo mknod -m 666 /dev/nvidia-uvm c $(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0 || true
# 			nvidia-smi

# 			    echo 'GPU software already installed; exiting'
# 			        exit 0
# 			fi

# Drivers not available, install them
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update -y
sudo apt-get purge -y nvidia*
sudo apt-get autoremove -y
sudo apt-get install -y dkms build-essential linux-headers-generic ntp ca-certificates curl

# You can change the version numbers, but ** DON'T CHANGE ** the format of these
# two statements, because other scripts read the Nvidia driver version from here!
NVIDIA_DRIVER_MAJOR=375
NVIDIA_DRIVER_MINOR=66

# There are also DEB packages for Ubuntu, but they install the full Gnome desktop !
wget -P /tmp http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_MAJOR}.${NVIDIA_DRIVER_MINOR}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_MAJOR}.${NVIDIA_DRIVER_MINOR}.run

sudo chmod +x /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_MAJOR}.${NVIDIA_DRIVER_MINOR}.run
sudo /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_MAJOR}.${NVIDIA_DRIVER_MINOR}.run --silent --dkms

cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
sudo update-initramfs -u

# Fix nvidia-uvm module rules
echo nvidia-uvm | sudo tee /etc/modules-load.d/nvidia-uvm.conf
cat <<EOF | sudo tee /etc/udev/rules.d/70-nvidia-uvm.rules
KERNEL=="nvidia_uvm", RUN+="/bin/bash -c '/bin/mknod -m 666 /dev/nvidia-uvm c \$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0;'"
EOF
sudo modprobe nvidia-uvm

# Make sure Nvidia devices are initialised on boot
cat <<EOF | sudo tee /etc/rc.local
#!/bin/sh -e
/usr/bin/nvidia-smi
exit 0
EOF
nvidia-smi
