## config.json File Options

The config.json file passed to /templates/create-templates.py contains sections to identify the cluster configuration options. The `config.json.example` file is provided as a base for customisation rather than attempting to build a configuration from scratch.

>NOTE: Not all combinations of options are valid - for example, if you chose not to configure any valid NFS storage for the cluster then the portainer helm chart will fail to deploy since it requires persistent kubernetes storage (PVC/PV).

The file sections are:

|Section|Description|
|---|---|
|target_hv|Select which hypervisor platform will be the deployment target, currently only VMware vCenter is supported|
|kubernetes_cluster|Defines the cluster configuration including names/IP addresses of control-plane and worker nodes together with sizing and cluster options. Also included is the ability to select whether additional helm charts (e.g. portainer, traefik) are also installed on the cluster during creation|
|nfs_server|Optional deployment of NFS server (using the same Photon OS template as the kubernetes cluster nodes) to provide persistent storage to the cluster|
|vcenter_environment|Defines the target vCenter cluster environment for the deployment. Parameters here are used both by packer for the initial template VM build and by ansible for the cluster bring-up|
|networking|This section details the environment networking - if you chose to use DNS the DNS domain and servers provided here should resolve entries for the VMs to be deployed from the `kubernetes_cluster` and `nfs_server` sections and should also provide name resolution for the `cluster_hostname`|
|vm_template|This section provides configuration details for the template VM built by packer, including the password to be assigned to the `root` user account|
|download_links|This section provides the URLs used to download each installed component in the template VM (by packer) and on the kubernetes cluster itself (by ansible)|

Most of the options should be reasonably self-explanatory, some notes below in an attempt to avoid issues:

- The admin workstation used to deploy the cluster needs `packer` and `ansible` installed on it together with some other dependencies - see the [admin-workstation](admin-workstation.md) file for details of building a suitable host/VM (based on Photon OS) to do this and details of which additional components are required. It should be possible to configure a Windows host to act as an admin workstation, but I have not attempted this.

- The numbers of cluster control-plane and worker nodes are completely configurable (simply add/remove lines in the `config.json` file) - you can build clusters with 1 control-plane node and 20 worker nodes or any other (valid) combination. The only restrictions are that there must be at least 1 control-plane node (to bootstrap the cluster) and one worker node (unless you 'untaint' the control-plane nodes - see below). The `config.json` file needs to be a valid `JSON` document so pay attention to commas etc. on line endings.

- If you are using the 'hosts' option for name resolution (`networking.use_hosts_file`) then an `/etc/hosts` file will be created on each deployed kubernetes node which has entries for all cluster nodes together with the `nfs_server` and the `cluster_hostname`. You will need to copy/add these entries to any admin workstation outside of the cluster to be able to resolve these names.

- The admin machine used to run the scripts to deploy the cluster must be able to communicate with both vCenter and the `vcenter_environment.vm_network_pg` selected for the cluster VMs to be deployed in.

- DHCP is **required** for the `vcenter_environment.vm_network_pg` as the template VM build needs this - I may look at removing this requirement in future and allowing static addressing for the template VM.

- If using an existing NFS server, the `nfs_server.deploy_nfs` entry can be `false` and then `nfs_hostname`, `nfs_dns_domain` and `nfs_mount_path` options used which will configure the cluster to use the existing NFS share.

- The minimum size for cluster control-plane and worker nodes appears to be ~2 vCPUs and 4GB RAM each, any smaller than this may fail to properly initialize the cluster (although I have managed to get 1 vCPU and 2GB RAM working it's inconsistent).

- The `kubernetes_cluster.schedule_pods_on_control_plane_nodes` option simply removes the kubernetes taint on control-plane nodes once deployed to allow pods to run on them which can be useful if available resources are tight.

- It is possible to re-run the `deploy.sh` script after modifying the `config.json` file (for example to add additional cluster worker nodes), but this has not been extensively tested and may break. Adding worker nodes in this way should be relatively safe.

- If you run your own private Certification Authority (CA), providing the CA certificate in `vm_template.trusted_root_CA` causes the template VM and all deployed cluster nodes to automatically trust this CA and any certificates generated by it.

