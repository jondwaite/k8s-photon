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
- portainer (optional)
- traefik (LoadBalancer / reverse proxy) (optional)
- NFS server based on Photon OS (persistent cluster storage) (optional)

This repository contains code to:

- Create configuration files for packer and ansible using the [Jinja2](https://jinja.palletsprojects.com/en/3.1.x/) templating engine
- Create a VM template using hashicorp [packer](https://www.packer.io/)
- Deploy the cluster from the template using Red Hat [ansible](https://www.ansible.com/) to form a kubernetes cluster which can then be used

The scripts as written target a VMware vSphere environment, but should be reasonably easy to adapt to target any virtualisation platform.

## Environment

This repository has been developed using:

|Component|Version|
|---|---|
|Hashicorp Packer|v1.11.2|
|Red Hat Ansible|v2.14.12|
|vCenter/ESXi|8.0U3|

## Usage

For instructions on configuring a suitable administration image to run cluster deployments, see [admin-workstation.md](admin-workstation.md).

The usage sequence is:

1) Copy the `config.json.example` file in the root of this repository and update the configuration values to suit your environment, if saved as `config.json` it will be used automatically in the next step. See [config-options.md](config-options.md) for details of the settings in this file
2) Run `deploy.sh` from the root of the repository, if you've named the configuration as anything other than `config.json` pass the filename of your configuration as a parameter to `deploy.sh` (e.g. `.\deploy.sh myconfig.json`)
3) Wait for the template VM and then cluster build to complete
4) Download the cluster config file from `/root/.kube/config` on any of the cluster nodes and use the cluster with kubectl

If you've used the `hosts` file option when deploying the cluster, you'll also need to add appropriate entries for the cluster nodes and hostname to the machine you'll access the cluster from (see [config-options.md](config-options.md))

The versions of components used are (at the time of writing) the most recent release versions of the components and will be ahead (considerably in some cases) of the versions obtainable from the Photon OS repositories available through `tdnf` - this is intentional as one of the goals of this project was to be able to expirement with the 'latest and greatest' features and capabilities.

> **NOTE** [this](https://kiwicloud.ninja/2024/09/automated-kubernetes-with-packer-and-ansible/) blog post contains more details on this repository
