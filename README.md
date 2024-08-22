# Photon OS 5.0 Kubernetes Cluster

## Introduction

I wanted a way to deploy [kubernetes](https://kubernetes.io) clusters for testing and development work that contained the latest released versions of code (both from the kubernetes project itself, but also additional  components like [Calico](https://docs.tigera.io/calico/latest/about/) networking and [containerd](https://containerd.io/))

I also wanted to make the deployed clusters as 'production-like' as possible - this included having a clustered control-plane with no single points of failure using a virtual IP (VIP) for access to the cluster itself using [kube-vip](https://kube-vip.io/)

Finally, I wanted to automate deployment as much as possible to minimise the overhead in creating and deploying these clusters.

The components currently deployed are:

- VMware Photon OS v5.0
- `containerd` v1.7.20
- `runc` v1.1.13
- CNI plugins v1.5.1
- `nerdctl` v1.7.6
- `calicoctl` v3.28.1
- `kubectl` v1.31.0
- `kubectl-convert` v1.31.0
- `crictl` v1.31.0
- `kubeadm` v1.31.0
- `kubelet` v1.31.0

This repository contains code to:

- Create a VM template using hashicorp [packer](https://www.packer.io/)
- Deploy the VM template using Red Hat [ansible](https://www.ansible.com/) to form a complete functional kubernetes environment which can then be used

The scripts as written target a VMware vSphere environment, but should be reasonably easy to adapt to target any virtualisation platform.

## Environment

This repository has been developed using:

|Component|Version|Notes|
|---|---|---|
|Hashicorp Packer|v1.11.1|Need to run `packer init` to pull in the required VMware plugin|
|Red Hat Ansible|v2.14.12|Need to run `ansible-galaxy collection install community.vmware` to provide the community.vmware module used|
|vCenter/ESXi|8.0U3|Any vCenter/ESXi version from 7.0 or later should work, vCenter is not strictly required and the scripts could likely be updated to work directly against ESXi hosts|

## Usage

The envisaged usage sequence is:

1) Clone the repository to an 'admin' workstation which has both packer and ansible installed/available.
2) Rename `config.auto.pkrvars.hcl.example` to `config.auto.pkrvars.hcl` in the `packer` folder and update as appropriate for your target environment
3) Run `packer init .` and `packer build .` from the `packer` folder to create the cluster template VM.
4) Rename `environment.yaml.example` and `secrets.yaml.example` in the `ansible\group_vars\all` folder to remove the `.example` suffix and adjust values as appropriate for your environment. Also review `cluster.yaml` and make any naming changes.
5) Review `ansible\inventory.yaml` and create DNS entries for each host and for the cluster name (`control_plane_hostname` in `ansible/group_vars/all/cluster.yaml`).
6) Review `ansible\inventory.yaml` for the sizing (RAM, CPUs and disk storage) for each type of node (control-plane and worker nodes)
7) Run `ansible-playbook site.yaml` from the `ansible` folder to deploy the defined kubernetes cluster
> **NOTE:** Without functoning DNS resolution for all hosts and `control_plane_hostname` the kubernetes cluster won't form.

A 'bare-bones' VM template can be manually built and the script `k8s-setup-manual.sh` from the `packer\data\scripts` folder run inside it to perform (mainly) the same actions as the packer build in case of any issues with packer.

> **NOTE:** if using `k8s-setup-manual.sh` there is no automated configuration of trusted root CA certificate or addition of SSH keys to authorized_keys as with the packer automated build.

Note that the versions of components used are (at the time of writing) the most recent release versions of the components and will be ahead (considerably in some cases) of the versions obtainable from the Photon OS repositories available through `tdnf` - this is intentional as one of the goals of this project was to be able to expirement with the 'latest and greatest' features and capabilities.

> **NOTE** This repository is intended to be accompanied by a blog post which will be linked here once available