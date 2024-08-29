packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= 1"
    }
  }
}

locals {
  install_media = "[${var.iso_datastore}] ${var.iso_path}/${var.iso_filename}"

  data_source_content = {
    "/ks.json" = templatefile("${abspath(path.root)}/data/ks.pkrtpl.hcl",
      { root_password = var.root_password }
    )
  }
}

source "vsphere-iso" "k8s-ph5" {

  # vCenter Details
  username                = var.vcenter_user
  password                = var.vcenter_password
  vcenter_server          = var.vcenter_server
  insecure_connection     = var.vcenter_insecure_connection
  datacenter              = var.vcenter_datacenter
  cluster                 = var.vcenter_cluster
  datastore               = var.vcenter_datastore
  folder                  = var.vm_folder

  # Template VM Configuration
  vm_name                 = var.vm_name
  guest_os_type           = var.guest_ostype
  firmware                = var.firmware
  vm_version              = var.vm_hw_version
  CPUs                    = var.num_cpus
  cpu_cores               = var.num_cpu_cores
  RAM                     = var.num_vram_mb
  NestedHV                = var.nestedhv
  network_adapters {
    network               = var.vcenter_network
    network_card          = "vmxnet3"
  } 
  cdrom_type              = "sata" 
  disk_controller_type    = ["pvscsi"]
  storage {
    disk_size             = var.disk_size_mb
    disk_thin_provisioned = var.disk_thin_provisioned
  }

  # Removable Media
  iso_paths               = [ local.install_media ]
  cd_content              = local.data_source_content

  # Build Settings
  boot_order              = "disk,cdrom"
  boot_command = [
    "<esc><wait>c",
    "linux /isolinux/vmlinuz root=/dev/ram0 loglevel=3 insecure_installation=1 ks=/dev/sr1:/ks.json photon.media=cdrom",
    "<enter>", "initrd /isolinux/initrd.img", "<enter>", "boot", "<enter>"
  ]

  boot_wait               = "-1s" # Don't pause before starting 'boot_command' sequence - seems to work best for Photon
  ip_wait_timeout         = "20m"
  communicator            = "ssh"
  ssh_port                = 22
  ssh_username            = "root"
  ssh_password            = var.root_password
  ssh_timeout             = "30m"
  shutdown_command        = "echo 'packer'|sudo systemctl poweroff"
  shutdown_timeout        = "10m"
  remove_cdrom            = true
  convert_to_template     = true

}

build {
  name = "k8s-ph5"
  sources = [
    "vsphere-iso.k8s-ph5"
  ]

  provisioner "shell" {
    environment_vars = [
      "DL_CONTAINERD=${var.dl_containerd}",
      "DL_CONTAINERD_SERVICE=${var.dl_containerd_service}",
      "DL_RUNC=${var.dl_runc}",
      "DL_CNI_PLUGINS=${var.dl_cni_plugins}",
      "DL_NERDCTL=${var.dl_nerdctl}",
      "DL_CALICOCTL=${var.dl_calicoctl}",
      "DL_KUBECTL=${var.dl_kubectl}",
      "DL_KUBECTL_CONVERT=${var.dl_kubectl-convert}",
      "DL_CRICTL=${var.dl_crictl}",
      "DL_KUBEADM_KUBELET=${var.dl_kubeadm-kubelet}",
      "DL_KUBELET_SERVICE=${var.dl_kubelet-service}",
      "DL_KUBEADM_CONFIG=${var.dl_kubeadm-config}",
      "SSH_KEY=${var.ssh_key}",
      "TRUSTED_CA_ROOT=${var.trusted_CA_root}"
    ]
    env_var_format = "export %s='%s'\n"
    scripts = [
      "./data/scripts/k8s-setup.sh"
    ]
  }
}
