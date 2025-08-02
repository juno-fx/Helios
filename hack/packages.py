import os
import sys
import yaml
from glob import glob

from pprint import pprint

package_dir = sys.argv[1]
dump_dir = sys.argv[2]
inherits = []
package_mappings = {}
package_lists = {}

for package_list in glob(f"{package_dir}/*.yaml"):
    if package_list.endswith("inherit.yaml"):
        inherits.append(package_list)
        continue
    # load packages yaml
    with open(package_list, 'r') as packages:
        spec: dict = yaml.load(packages, yaml.loader.FullLoader)
    loaded_packages: dict = spec['packages']
    for package in loaded_packages:
        for distro in package.keys():
            package_mappings.setdefault(distro, []).append(package[distro])

os.makedirs(dump_dir, exist_ok=True)

for inherit_file in inherits:
    with open(inherit_file, 'r') as inherit_handler:
        spec: dict = yaml.load(inherit_handler, yaml.loader.FullLoader)
    inherit: dict = spec['inherit']
    for distro in inherit.keys():
        packages = package_mappings[distro]
        for parent in inherit[distro]:
            packages.extend(package_mappings[parent])
        compiled = set(packages)
        package_lists.setdefault(distro, []).extend(compiled)

for distro, packages in package_lists.items():
    print(f"{distro}: {len(packages)} packages")
    with open(os.path.join(dump_dir, f"{distro}.list"), 'w') as package_list_handler:
        package_list_handler.write(' '.join(set(packages)))
