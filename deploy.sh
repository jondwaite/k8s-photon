#!/bin/bash

# You must configure ./templates/config.json prior to running this script - it won't work without a configuration!

if [[ ! -f ./templates/config.json ]] ; then
  echo "The config.json file doesn't exist in the templates folder"
  echo "Copy and update the config.json.example file to suit your environment"
  exit
fi

echo "Creating configuration files from templates..."
cd templates
./create-templates.py

echo "Building template VM..."
cd ../packer
packer init .
packer build .

echo "Deploying Cluster..."
cd ../ansible
ansible-playbook site.yaml
exit
