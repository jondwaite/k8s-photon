variable "root_password" {
	type = string
	sensitive = true
	description = "The password to be assigned to the 'root' user in the template VM"
}

variable "vcenter_user" {
    type = string
    description = "The user account used to connect to vCenter"
}

variable "vcenter_password" {
    type = string
    sensitive = true
    description = "The password used to connect to vCenter"
}

variable "vcenter_server" {
	type = string
	description = "FQDN or IP address of vCenter server to be used for the build"
}

variable "vcenter_insecure_connection" {
	type = bool
	default = true
	description = "Whether to allow insecure connections to vCenter"
}

variable "vcenter_datacenter" {
	type = string
	default = "dc01"
	description = "The vCenter datacenter to be used for the build"
}

variable "vcenter_cluster" {
	type = string
	default = "cl01"
	description = "The vCenter cluster to be used for the build"
}

variable "vcenter_datastore" {
	type = string
	default = "vsanDatastore"
	description = "The vCenter datastore to be used for the build"
}

variable "vcenter_network" {
	type = string
	default = "VMNetwork"
	description = "The vCenter network the build VM will use (needs DHCP enabled)"
}

variable "NestedHV" {
	type = bool
	default = true
	description = "Whether the deployed template VM supported nested virtualization"
}

variable "iso_datastore" {
	type = string
	default = "iso"
	description = "The name of the datastore containing the photon OS ISO file"
}
variable "iso_path" {
	type = string
	default = "linux/photon"
	description = "The datastore path where the photon OS ISO file is located"
}

variable "iso_filename" {
	type = string
	default = "photon-minimal-5.0-dde71ec57.x86_64.iso"
	description = "The filename of the ISO file to be used for the build"
}

variable "vm_name" {
	type = string
	default = "k8s-photon-tmpl"
	description = "The name of the VM template to be built"
}

variable "vm_folder" {
	type = string
	default = "Kubernetes"
	description = "The VM folder for the VM template to be built in"
}

variable "num_cpus" {
	type = number
	default = 2
	description = "The number of vCPUs to assign to the template VM"
}

variable "num_cpu_cores" {
	type = number
	default = 1
	description = "The number of CPU cores to assign to each vCPU"
}

variable "num_vram_mb" {
	type = number
	default = 8192
	description = "RAM amount (in MB) to assign to the template VM"
}

variable "disk_size_mb" {
	type = number
	default = 16384
	description = "Disk size (in MB) to assign to the template VM"
}

variable "disk_thin_provisioned" {
	type = bool
	default = true
	description = "Whether the template VM disk should be thin provisioned"
}

variable "firmware" {
	type = string
	default = "efi-secure"
	description = "Firmware type for the template VM"
	validation {
		condition    	= contains(["bios","efi","efi-secure"], var.firmware)
		error_message 	= "Allowed values for firmware are \"bios\", \"efi\" or \"efi-secure\"."
	}
}

variable "vm_hw_version" {
	type = number
	default = 19
	description = "The VM hardware version to be used for the template VM"
}

variable "guest_ostype" {
	type = string
	default = "vmwarePhoton64Guest"
	description = "The VMware Guest OS type for the template VM"
}

# Download location variables (values supplied by config.auto.pkrvars.hcl)

variable "dl_containerd" {
	type = string
	description = "Download link for containerd binary"
}

variable "dl_containerd_service" {
	type = string
	description = "Download link for containerd service file"
}

variable "dl_runc" {
	type = string
	description = "Download link for runc binary"
}

variable "dl_cni_plugins" {
	type = string
	description = "Download link for CNI plugins binaries"
}

variable "dl_nerdctl" {
	type = string
	description = "Download link for nerdctl binary"
}

variable "dl_calicoctl" {
	type = string
	description = "Download link for calicoctl"
}

variable "dl_kubectl" {
	type = string
	description = "Download link for kubectl binary"
}

variable "dl_kubectl_convert" {
	type = string
	description = "Download link for kubectl-convert binary"
}

variable "dl_crictl" {
	type = string
	description = "Download link for crictl binary"
}

variable "dl_kubeadm_kubelet" {
	type = string
	description = "Download link for kubeadm and kubelet binaries"
}

variable "dl_kubelet_service" {
	type = string
	description = "Download link for service file for kubelet"
}

variable "dl_kubeadm_config" {
	type = string
	description = "Download link for kubeadm conf file"
}

variable "ssh_key" {
	type = string
	default = ""
	description = "SSH key to allow external access (added to authorized_keys in template)"
}

variable "trusted_CA_root" {
	type = string
	default = ""
	description = "Public certificate for a private root Certificate Authority (CA) to be trusted by deployed nodes"
}
