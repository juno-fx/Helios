import os
import sys
import yaml

from pprint import pprint

dump_dir = sys.argv[2]

# load packages yaml
with open(sys.argv[1], 'r') as packages:
    spec: dict = yaml.load(packages, yaml.loader.FullLoader)

loaded_packages: dict = spec['packages']

package_mappings = {}
for package in loaded_packages:
    for distro in package.keys():
        package_mappings.setdefault(distro, []).append(package[distro])

os.makedirs(dump_dir, exist_ok=True)

inherit: dict = spec['inherit']
for distro in inherit.keys():
    packages = package_mappings[distro]
    for parent in inherit[distro]:
        packages.extend(package_mappings[parent])
    compiled = set(packages)
    print(f"{distro}: {len(compiled)} packages")
    with open(os.path.join(dump_dir, f"{distro}.list"), 'w') as package_list_handler:
        package_list_handler.write(' '.join(set(packages)))
