{
  "hostname": "k8s-ph5",
  "password": {
    "crypted": false,
    "text": "${root_password}"
  },
  "disk": "/dev/sda",
  "partitions": [
    {"mountpoint": "/", "size": 0, "filesystem": "ext4"},
    {"mountpoint": "/boot", "size": 128, "filesystem": "ext4"}
  ],
  "bootmode": "efi",
  "packagelist_file": "packages_minimal.json",
  "additional_packages": ["vim"],
  "postinstall": [
    "#!/bin/sh",
    "/bin/sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config",
    "/bin/systemctl restart sshd.service"
  ],
  "install_linux_esx": true,
  "ui": true,
  "network": {
    "type": "dhcp"
  }
}
