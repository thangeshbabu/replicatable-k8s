# Disable swap 
sudo sed -i '/swap/d' /etc/fstab
swapoff -a


##### kuberentes networking prerequsite

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system



# install container runtime 
# ref: https://github.com/containerd/containerd/blob/main/docs/getting-started.md
# ref: https://docs.docker.com/engine/install/ubuntu/

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

# Add docker official gpg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up repository 
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

# Install containerd
sudo apt-get install containerd.io

# Enable containerd service
systemctl daemon-reload
systemctl enable --now containerd

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

#set systemd as cgroupdriver
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

#restart containerd service
sudo systemctl restart containerd

# install kubeadm kubelet and kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1
sudo apt install -qq -y kubeadm=1.27.0-00 kubelet=1.27.0-00 kubectl=1.27.0-00 >/dev/null 2>&1
sudo apt-mark hold kubelet kubeadm kubectl

# vagrant specific 
echo "[TASK 8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sudo systemctl reload sshd

echo "[TASK 9] Set root password"
echo -e "999\n999" | sudo passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 10] Update /etc/hosts file"

sudo cat >>/etc/hosts<<EOF
172.16.17.100   masternode.lan.com    masternode
172.16.17.101   workernode1.lan.com    workernode1
172.16.17.102   workernode2.lan.com    workernode2
EOF



