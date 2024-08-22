#!/bin/bash

# Package management
echo "tdnf: Updating all packages"
tdnf update -y -q &>/dev/null

echo "tdnf: Removing docker, containerd and runc"
tdnf remove -y -q docker* containerd* runc

echo "tdnf: Installing wget, tar, jq, socat, ethtool, conntrack, git and nfs-utils"
tdnf install -y -q wget tar jq socat ethtool conntrack git nfs-utils 2>&1

# Set up firewall rules
echo "Configuring firewall rules"
iptables -A INPUT -p tcp --dport 179 -j ACCEPT
iptables -A INPUT -p tcp --dport 2379:2380 -j ACCEPT
iptables -A INPUT -p udp --dport 4789 -j ACCEPT
iptables -A INPUT -p tcp --dport 5473 -j ACCEPT
iptables -A INPUT -p tcp --dport 6443 -j ACCEPT
iptables -A INPUT -p udp --dport 8285 -j ACCEPT
iptables -A INPUT -p udp --dport 8472 -j ACCEPT
iptables -A INPUT -p tcp --dport 10250 -j ACCEPT
iptables -A INPUT -p tcp --dport 10256 -j ACCEPT
iptables -A INPUT -p tcp --dport 10257 -j ACCEPT
iptables -A INPUT -p tcp --dport 10259 -j ACCEPT
iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT
iptables -A INPUT -p ip -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

# Configuring SSH keys
echo "Configuring ssh keys"
ssh-keygen -t rsa -b 4096 -N '' <<< $'\ny' >/dev/null 2>&1
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
if [ -n "${SSH_KEY}" ]; then
    echo "Adding specified SSH key to authorized_keys"
    echo -e "\n$SSH_KEY" >> ~/.ssh/authorized_keys
else
    echo "No SSH key specified to add to authorized_keys, skipping"
fi

# Configure Trusted Root CA
if [ -n "${TRUSTED_CA_ROOT}" ]; then
    echo "Configuring Root CA Trust"
    echo -e "$TRUSTED_CA_ROOT" > /etc/ssl/certs/trusted-ca.pem
    /usr/bin/rehash_ca_certificates.sh
else
    echo "No additional root CA specified to trust, skipping"
fi

# Configure kernel modules
echo "Configuring kernel modules"
echo overlay > /etc/modules-load.d/20-containerd.conf
echo br_netfilter >> /etc/modules-load.d/20-containerd.conf
modprobe overlay
modprobe br_netfilter

# Configure sysctl IP forwarding
echo "Configuring IPv4 forwarding"
echo net.ipv4.ip_forward=1 > /etc/sysctl.d/60-kubernetes.conf
sysctl --system &>/dev/null

# Create and move to downloads directory
echo "Starting downloads"
mkdir ~/k8s-downloads
cd ~/k8s-downloads

# Install containerd:
echo "Downloading containerd from $DL_CONTAINERD"
wget -nv "$DL_CONTAINERD" 2>&1
tar Czxvf /usr/local containerd*.tar.gz
echo "Downloading containerd service definition from $DL_CONTAINERD_SERVICE"
wget -nv -P /usr/local/lib/systemd/system "$DL_CONTAINERD_SERVICE" 2>&1

# Install runc:
echo "Downloading runc from $DL_RUNC"
wget -nv "$DL_RUNC" 2>&1
install runc.amd64 -o root -g root -m 0755 /usr/bin/runc

# Install CNI plugins:
echo "Downloading CNI-plugins from $DL_CNI_PLUGINS"
wget -nv "$DL_CNI_PLUGINS" 2>&1
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64*.tgz

# Configure containerd:
echo "Configuring containerd"
/usr/local/bin/containerd config default > /etc/containerd/config.toml
sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
sed -i 's/pause\:3.8/pause\:3.10/' /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable --now containerd 2>&1

# Install nerdctl:
echo "Downloading nerdctl from $DL_NERDCTL"
wget -nv "$DL_NERDCTL" 2>&1
tar Cxzvf /usr/local/bin nerdctl*.tar.gz

# Install calicoctl
echo "Downloading calicoctl from $DL_CALICOCTL"
wget -nv "$DL_CALICOCTL" 2>&1
install -o root -g root -m 0755 calicoctl-linux-amd64 /usr/local/bin/kubectl-calico

# Install kubernetes tools & pre-pull images:
echo "Downloading kubectl from $DL_KUBECTL"
curl -sSLO "$DL_KUBECTL"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "Downloading kubectl-convert from $DL_KUBECTL_CONVERT"
curl -sSLO "$DL_KUBECTL_CONVERT"
install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert 

echo "Downloading crictl from $DL_CRICTL"
curl -sSLO "$DL_CRICTL"
tar Czxvf /usr/local/bin crictl*.tar.gz

echo "Downloading kubeadm & kubelet from $DL_KUBEADM_KUBELET"
curl -sSL --remote-name-all "$DL_KUBEADM_KUBELET"
install -o root -g root -m 0755 kubeadm /usr/local/bin/kubeadm
install -o root -g root -m 0755 kubelet /usr/local/bin/kubelet

echo "Configuring kubelet service from $DL_KUBELET_SERVICE"
wget -nv -P /usr/local/lib/systemd/system "$DL_KUBELET_SERVICE" 2>&1
sed -i 's/\/usr\/bin\/kubelet/\/usr\/local\/bin\/kubelet/' /usr/local/lib/systemd/system/kubelet.service
mkdir -p /usr/local/lib/systemd/system/kubelet.service.d
echo "Configuring kubeadm config from $DL_KUBEADM_CONFIG"
wget -q -P /usr/local/lib/systemd/system/kubelet.service.d "$DL_KUBEADM_CONFIG" 2>&1
sed -i 's/\/usr\/bin\/kubelet/\/usr\/local\/bin\/kubelet/' /usr/local/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl enable --now kubelet 2>&1

echo "Pre-pulling kubernetes images"
kubeadm config images pull
echo "Done downloading"

# Bash completion:
echo "Setting bash completions"
cat <<EOF >> $HOME/.profile
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
EOF
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source $HOME/.bashrc

# Tidy up ready for cloning
echo "Tidying up"
cd
rm -rf ~/k8s-downloads
