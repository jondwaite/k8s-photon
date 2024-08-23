#!/usr/bin/env python3

from jinja2 import Template
import json

templates = []
templates.append({"tmpl":"inventory.yaml.tmpl", "output":"../ansible/inventory.yaml"})
templates.append({"tmpl":"cluster.yaml.tmpl", "output":"../ansible/group_vars/all/cluster.yaml"})
templates.append({"tmpl":"environment.yaml.tmpl", "output":"../ansible/group_vars/all/environment.yaml"})
templates.append({"tmpl":"config.auto.pkrvars.hcl.tmpl", "output":"../packer/config.auto.pkrvars.hcl"})
templates.append({"tmpl":"hosts.tmpl", "output":"hosts"})

print("Reading config.json...")
with open('config.json','r') as config:
    config_data = json.load(config)
print("Read config.json ok, generating configuration files from templates...")
for template in templates:
    with open(template['tmpl']) as template_file:
        content = template_file.read()
    template_object = Template(content)
    f = open(template['output'],"w")
    f.write(template_object.render(config_data))
    f.close()
    print(f"Generated '{template['output']}' from template '{template['tmpl']}' using config.json")
print("Done creating configuration files from templates - check for accuracy before using them")