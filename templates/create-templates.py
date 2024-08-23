#!/usr/bin/env python3

from jinja2 import Template
import json

with open('config.json','r') as config_file:
    config_data = json.load(config_file)

# Create 'inventory.yaml' from template:
with open('inventory.yaml.tmpl') as inventory_file:
    inventory_template = inventory_file.read()
inv_tmpl = Template(inventory_template)
f = open("../ansible/inventory.yaml","w")
f.write(inv_tmpl.render(config_data))
f.close()

# Create 'cluster.yaml' from template:
with open('cluster.yaml.tmpl') as cluster_file:
    cluster_template = cluster_file.read()
clu_tmpl = Template(cluster_template)
f = open("../ansible/group_vars/all/cluster.yaml","w")
f.write(clu_tmpl.render(config_data))
f.close()

# Create 'environment.yaml' from template:
with open('environment.yaml.tmpl') as env_file:
    env_template = env_file.read()
env_tmpl = Template(env_template)
f = open("../ansible/group_vars/all/environment.yaml","w")
f.write(env_tmpl.render(config_data))
f.close()

# Create 'config.auto.pkrvars.hcl' from template:
with open('config.auto.pkrvars.hcl.tmpl') as pac_file:
    pac_template = pac_file.read()
pac_tmpl = Template(pac_template)
f = open("../packer/config.auto.pkrvars.hcl","w")
f.write(pac_tmpl.render(config_data))
f.close()
