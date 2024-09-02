# Configure admin workstation for k8s-photon

Configure an administration VM for k8s-photon project - these steps are based on VMware Photon OS 5.0 minimal installation, but should be adaptable for any linux distribution/flavor.

## Prerequisites

- Build VM from Photon OS 5.0 ISO (photon-minimal-5.0-dde71ec57.x86_64.iso) - this ISO image will also be used by the VM build so note the datastore and path
- Assign (or use DHCP) IP address able to reach the internet and the network where the cluster will be deployed/built
- Create DNS host entries ready for the cluster/hosts defined in the configuration (if not using host files where each deployed cluster node gets a `hosts` file with all relevant IP addresses and hostnames in it)
- Ensure DHCP is available/functional on the build network (the initial template build VM needs this)
- Default installation of Photon OS 5 works fine, 8 GB of disk space is plenty and 1 vCPU / 4GB of RAM is fine. Total used disk space in testing for the admin VM is approx. 1.6 GB.

## Initial configuration

- After installing the new VM, log in to the VM console in vCenter and change `/etc/ssh/sshd_config` to permit ssh root login (`PermitRootLogin no` -> `PermitRootLogin yes`), then `systemctl restart sshd`
- SSH to the VM as the `root` user
- Update installed packages to latest versions: `tdnf update -y`
- Reboot the VM (to ensure the new packages/kernel are loaded)

## Install required tools

Install `git`, `cdrkit`, `wget`, `unzip`, `sshpass` and `python3-pip` from the Photon OS repository:

```
tdnf install -y git cdrkit wget unzip sshpass python3-pip
```

If you prefer `nano` to `vim` to edit the configuration files then install that too with `tdnf install -y nano`

### Install Hashicorp Packer

Install [`packer`](https://developer.hashicorp.com/packer) using:
```
wget https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip
unzip packer_1.11.2_linux_amd64.zip
install -m 755 packer /usr/local/bin
```

### Install Red Hat ansible

Install and configure [`ansible`](https://www.ansible.com/) using the following, pyvmomi is required for ansible to talk to vSphere:
```
rm -rf /usr/lib/python3.11/site-packages/setuptools-65.5.0.dist-info
pip install --upgrade pip --root-user-action=ignore
pip install ansible pyvmomi jsonpath openshift pyyaml kubernetes --root-user-action=ignore
```

### Clone the [k8s-photon](https://github.com/jondwaite/k8s-photon) repo

Using git:

```
git clone https://github.com/jondwaite/k8s-photon
cd k8s-photon
```

### Configure the deployment

Copy the template `config.json.example` in the repository root folder to `config.json`

```
cp config.json.example config.json
```

Edit the config.json file (e.g. `vim config.json`) and change values to suit the desired cluster and environment based on the example file.

### Deploy the cluster

Once `config.json` has been updated there are 3 steps to run:

1. Create the configuration files from templates (uses the values in `config.json` to build the packer and ansible configuration files)
2. Create the VM template (using packer)
3. Deploy the kubernetes cluster using the VM template as a base (using ansible)

Alternatively you can run `./deploy.sh` from the `k8s-photon` folder which will perform all 3 steps.

To do each step individually:

#### Create configuration files

```
cd templates
./create-templates.py <path and filename of config.json file>
cd ..
```

If you see any errors, it's likely parameters in the `config.json` are incorrect and need to be updated.

#### Create the VM template using packer

```
cd packer
packer init .
packer build .
cd ..
```

The template VM will be created with the VM template name and in the vCenter folder configured in `config.json`.

#### Deploy the kubernetes cluster using ansible

```
cd ansible
ansible-playbook site.yaml
cd ..
```

This will build the VMs for the control-plane and worker nodes to form a kubernetes cluster.

## What do you get?

The goal of this project was to familiarise myself more with the 'latest and greatest' features in Kubernetes and learn some more automation with `packer` and `ansible`. That said, I wanted the deployed clusters to be useable and as functional as possible. The configuration delivers (depending on options changed in the configuration files):

- Kubernetes v1.31 deployed cluster
- Highly available kubernetes control-plane using a kube-vip virtual IP to access the cluster
- Calico networking configured as CNI for pod networking
- kube-vip as a LoadBalancer capable of providing additional VIP addresses for publishing services from the cluster
- An NFS server configured as the default persistent storage for the cluster (optional)
- [portainer](https://www.portainer.io/) deployed into the cluster (with persistent storage)
- [traefik](https://traefik.io/traefik/) deployed into the cluster

# Using the cluster

Once successfully deployed, install `kubectl` (either on the admin machine used to deploy the cluster or anywhere else on your network). You can copy the `/root/.kube/config` file to `$HOME/.kube/config` to provide the cluster authentication and configuration information to `kubectl`.

You will likely need to create a `hosts` file entry or DNS entry for your cluster virtual IP / hostname in order to be able to connect to it by name (`config.json` parameters `cluster_hostname` and `cluster_ip`)

e.g. if using Photon OS for admin machine, you can simply copy kubectl and the config file from one of the deployed nodes (using example IP addressing):

```
scp root@172.30.16.11:/usr/local/bin/kubectl /usr/local/bin
mkdir ~/.kube
scp root@172.30.16.11:/root/.kube/config ~/.kube/
```

After this you should be able to see the newly deployed cluster nodes and pods:

```
kubectl get nodes -o wide
NAME           STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION      CONTAINER-RUNTIME
k8s-cl01-c01   Ready    control-plane   8m39s   v1.31.0   172.30.16.11   <none>        VMware Photon OS/Linux   6.1.102-1.ph5-esx   containerd://1.7.20
k8s-cl01-c02   Ready    control-plane   6m56s   v1.31.0   172.30.16.12   <none>        VMware Photon OS/Linux   6.1.102-1.ph5-esx   containerd://1.7.20
k8s-cl01-c03   Ready    control-plane   6m4s    v1.31.0   172.30.16.13   <none>        VMware Photon OS/Linux   6.1.102-1.ph5-esx   containerd://1.7.20
k8s-cl01-w01   Ready    <none>          4m14s   v1.31.0   172.30.16.14   <none>        VMware Photon OS/Linux   6.1.102-1.ph5-esx   containerd://1.7.20
k8s-cl01-w02   Ready    <none>          4m14s   v1.31.0   172.30.16.15   <none>        VMware Photon OS/Linux   6.1.102-1.ph5-esx   containerd://1.7.20
k8s-cl01-w03   Ready    <none>          4m14s   v1.31.0   172.30.16.16   <none>        VMware Photon OS/Linux   6.1.102-1.ph5-esx   containerd://1.7.20

kubectl get pods -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-68865dfcb6-ct5lr   1/1     Running   0          8m10s
kube-system   calico-node-bmbpq                          1/1     Running   0          4m30s
kube-system   calico-node-c4whx                          1/1     Running   0          4m30s
kube-system   calico-node-cz6kj                          1/1     Running   0          8m10s
kube-system   calico-node-f5crs                          1/1     Running   0          7m12s
kube-system   calico-node-qwqgq                          1/1     Running   0          4m30s
kube-system   calico-node-wpsjm                          1/1     Running   0          6m20s
kube-system   coredns-6f6b679f8f-5z7rd                   1/1     Running   0          8m45s
kube-system   coredns-6f6b679f8f-z744t                   1/1     Running   0          8m45s
kube-system   etcd-k8s-cl01-c01                          1/1     Running   0          8m52s
kube-system   etcd-k8s-cl01-c02                          1/1     Running   0          7m12s
kube-system   etcd-k8s-cl01-c03                          1/1     Running   0          6m19s
kube-system   kube-apiserver-k8s-cl01-c01                1/1     Running   0          8m52s
kube-system   kube-apiserver-k8s-cl01-c02                1/1     Running   0          7m10s
kube-system   kube-apiserver-k8s-cl01-c03                1/1     Running   0          6m18s
kube-system   kube-controller-manager-k8s-cl01-c01       1/1     Running   0          8m53s
kube-system   kube-controller-manager-k8s-cl01-c02       1/1     Running   0          7m10s
kube-system   kube-controller-manager-k8s-cl01-c03       1/1     Running   0          6m18s
kube-system   kube-proxy-dk4rq                           1/1     Running   0          4m30s
kube-system   kube-proxy-g44bm                           1/1     Running   0          4m30s
kube-system   kube-proxy-hqqjj                           1/1     Running   0          4m30s
kube-system   kube-proxy-jqn2w                           1/1     Running   0          7m12s
kube-system   kube-proxy-mnkw8                           1/1     Running   0          8m45s
kube-system   kube-proxy-x8hfj                           1/1     Running   0          6m20s
kube-system   kube-scheduler-k8s-cl01-c01                1/1     Running   0          8m52s
kube-system   kube-scheduler-k8s-cl01-c02                1/1     Running   0          7m10s
kube-system   kube-scheduler-k8s-cl01-c03                1/1     Running   0          6m18s
kube-system   kube-vip-k8s-cl01-c01                      1/1     Running   0          8m54s
kube-system   kube-vip-k8s-cl01-c02                      1/1     Running   0          6m44s
kube-system   kube-vip-k8s-cl01-c03                      1/1     Running   0          5m52s
```

Congratulations! - your cluster is now initialised and up and running ready to deploy whatever applications you need.
