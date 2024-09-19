#!/bin/bash

configfile=${1:-./config.json}

if [[ ! -f $configfile ]] ; then
  echo "No configuration file specified and no config.json found."
  echo "Copy the config.json.example file, adjust for your environmnent and save as config.json (to be used automatically) or pass the filename to deploy.sh"
  exit 1
fi

echo "Creating configuration files from templates..."
./templates/create-templates.py $configfile

echo "Building template VM..."
cd packer && packer init . && packer build .
cd ..

echo "Deploying Cluster..."
cd ansible && ansible-playbook site.yaml
cd ..

exit
