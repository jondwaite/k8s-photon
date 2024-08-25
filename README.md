# Photon OS 5.0 Kubernetes Cluster

## Introduction

I wanted a way to deploy [kubernetes](https://kubernetes.io) clusters for testing and development work that contained the latest released versions of code (both from the kubernetes project itself, but also additional  components like [Calico](https://docs.tigera.io/calico/latest/about/) networking and [containerd](https://containerd.io/))

I also wanted to make the deployed clusters as 'production-like' as possible - this included having a clustered control-plane with no single point of failure using a virtual IP (VIP) for access to the cluster itself using [kube-vip](https://kube-vip.io/)

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
- kube-vip cloud controller (LoadBalancer)
- portainer
- traefik (LoadBalancer / reverse proxy)
- NFS server based on Photon OS (persistent cluster storage)

This repository contains code to:

- Create configuration files for packer and ansible using the [Jinja2](https://jinja.palletsprojects.com/en/3.1.x/) templating engine
- Create a VM template using hashicorp [packer](https://www.packer.io/)
- Deploy the cluster from the template using Red Hat [ansible](https://www.ansible.com/) to form a kubernetes environment which can then be used

The scripts as written target a VMware vSphere environment, but should be reasonably easy to adapt to target any virtualisation platform.

## Environment

This repository has been developed using:

|Component|Version|
|---|---|
|Hashicorp Packer|v1.11.1|
|Red Hat Ansible|v2.14.12|
|vCenter/ESXi|8.0U3|

## Usage

The envisaged usage sequence is:

1) Copy the `config.json.example` file in the root of the repository and update the configuration values to suit your environment, if saved as `config.json` it will be used automatically in the next step.
2) Run `deploy.sh` from the root of the repository, if you've named the configuration as anything other than `config.json` pass the filename of your configuration as a parameter to `deploy.sh`
3) Wait until the cluster build is completed
4) Download the cluster 'config' file from /root/.kube/config on any of the cluster nodes and use the cluster with kubectl

A 'bare-bones' VM template can be manually built and the script `k8s-setup-manual.sh` from the `packer\data\scripts` folder run inside it to perform (mainly) the same actions as the packer build in case of any issues with packer.

> **NOTE:** if using `k8s-setup-manual.sh` there is no automated configuration of trusted root CA certificate or addition of SSH keys to authorized_keys as with the packer automated build.

Note that the versions of components used are (at the time of writing) the most recent release versions of the components and will be ahead (considerably in some cases) of the versions obtainable from the Photon OS repositories available through `tdnf` - this is intentional as one of the goals of this project was to be able to expirement with the 'latest and greatest' features and capabilities.

> **NOTE** This repository is intended to be accompanied by a blog post which will be linked here once available