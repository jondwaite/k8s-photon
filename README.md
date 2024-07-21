# Packer Build for Photon 5 Kubernetes Template VM

This repository contains files for automated build, configuration and deployment of a VMware Photon OS v5 image using Hashicorp `packer` ready to be configured as part of a Kubernetes cluster (k8s) to be deployed to a vSphere environment as virtual machines. The way the scripts are written this should be easily adjustable to alternative virtualization platforms. The components and versions are:

- VMware Photon OS v5.0
- `containerd` v1.7.19
- `runc` v1.1.13
- CNI plugins v1.5.1
- `nerdctl` v1.7.6
- `calicoctl` v3.28.0
- `kubectl` v1.30.2
- `kubectl-convert` v1.30.2
- `crictl` v1.30.1
- `kubeadm` v1.30.2
- `kubelet` v1.30.2

The envisaged usage sequence is:

1) Clone the repository, update `config.auto.pkrvars.hcl` in the `packer` folder as appropriate for the target environment
2) Run `packer init .` and `packer build .` from the `packer` folder to create a template VM
3) Once a template has been successfully built, the `deploy.ps1` PowerShell script in the `powershell` folder can be used with PowerCLI to deploy VMs for the cluster
4) From within the deployed cluster VMs, run `kubeadm` to initialize/build the `kubernetes` cluster and configure components

Alternatively, a 'bare-bones' VM template can be manually built and the script `k8s-setup-manual.sh` from the `packer\data\scripts` folder run inside it to perform (mainly) the same actions as the packer build in case of any issues with packer.

Note that the versions of components used are (at the time of writing) the most recent release versions of the components and will be ahead (considerably in some cases) of the versions obtainable from the Photon OS repositories available through `tdnf` - this is intentional as one of the goals of this project was to be able to expirement with the 'latest and greatest'.

> **NOTE** This repository is intended to be accompanied by a blog post which will be linked here once available