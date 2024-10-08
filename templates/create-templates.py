#!/usr/bin/env python3

# Uses jinja2 with template files in ./templates/ to generate packer and ansible configuration 
# based on supplied config file:
#
#  'inventory.yaml.tmpl' becomes 'ansible/inventory.yaml'
#  'cluster.yaml.tmpl' becomes 'ansible/group_vars/all/cluster.yaml'
#  'environment.yaml.tmpl' becomes 'ansible/group_vars/all/environment.yaml'
#  'config.auto.pkrvars.hcl.tmpl' becomes 'packer/config.auto.pkrvars.hcl'

from jinja2 import Template
import json
import sys
import os

configfile = sys.argv[1]
scriptpath = os.path.dirname(os.path.realpath(__file__))
parentpath = os.path.dirname(scriptpath)

templates = []
templates.append({"tmpl":"inventory.yaml.tmpl", "output":"ansible/inventory.yaml"})
templates.append({"tmpl":"cluster.yaml.tmpl", "output":"ansible/group_vars/all/cluster.yaml"})
templates.append({"tmpl":"environment.yaml.tmpl", "output":"ansible/group_vars/all/environment.yaml"})
templates.append({"tmpl":"downloads.yaml.tmpl", "output":"ansible/group_vars/all/downloads.yaml"})
templates.append({"tmpl":"config.auto.pkrvars.hcl.tmpl", "output":"packer/config.auto.pkrvars.hcl"})

print(f"Reading config file '{configfile}'...")
with open(configfile,'r') as config:
    config_data = json.load(config)

print("Read config file read ok, generating configuration files from templates...")
for template in templates:
    with open(os.path.join(scriptpath, template['tmpl'])) as template_file:
        content = template_file.read()
    template_object = Template(content)
    f = open(os.path.join(parentpath,template['output']),"w")
    f.write(template_object.render(config_data))
    f.close()
    print(f"Generated '{template['output']}' from template '{template['tmpl']}' using config file '{configfile}'.")

print("Done creating configuration files from templates - check for accuracy before using them")
