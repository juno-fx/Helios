import mkdocs_gen_files
from glob import glob

plugins = glob("plugins/*/terra.yaml")

def generate(plugin):
    template = f"""
```yaml linenums="1" title="{plugin}"
--8<-- "{plugin}"
```
"""
    return template



for plugin in plugins:
    nav = mkdocs_gen_files.Nav()
    icon = None
    description = None
    category = None
    with open(plugin, "r") as f:
        plugin_data = f.read()
        plugin_data = plugin_data.splitlines()
        for line in plugin_data:
            if line.startswith("icon:"):
                icon = line.replace("icon:", "").strip()
            elif line.startswith("description:"):
                description = line.replace("description:", "").strip()
            elif line.startswith("category:"):
                category = line.replace("category:", "").strip()

    plugin_name = plugin.split('/')[1]
    plugin_path = f"plugins/{category}/{plugin_name}.md"
    with mkdocs_gen_files.open(plugin_path, "w") as f:
        if icon:
            print(f"![icon]({icon})" + '{width="100"}', file=f)
            print("<br/>", file=f)
        if description:
            print(f"<p>{description}</p>", file=f)
            print("---", file=f)
        print(generate(plugin), file=f)

    nav["Plugins", plugin_name] = plugin_path
