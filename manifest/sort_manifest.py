import os
import subprocess
import xml.etree.ElementTree as Tree
from xml.etree.ElementTree import Element

for var in ["TARGET_MANIFEST_PATH", "SORTED_MANIFEST_PATH"]:
    if var not in os.environ:
        raise EnvironmentError("Required env variable {} is not set.".format(var))

TARGET_MANIFEST_PATH = os.getenv('TARGET_MANIFEST_PATH')
SORTED_MANIFEST_PATH = os.getenv('SORTED_MANIFEST_PATH')
print(f"sort manifest {TARGET_MANIFEST_PATH} to {SORTED_MANIFEST_PATH}")


def get_sorting_weight(node: Element):
    """Return the sorting key of android manifest nodes.
    Some special tags should be on top
    """
    if node.tag.startswith("uses-sdk"):
        return 1
    if node.tag.startswith("uses-feature"):
        return 2
    if node.tag.startswith("uses-permission"):
        return 3
    if node.tag.startswith("permission"):
        return 4
    return 5


def get_attribute(node: Element):
    name_attribute = "{http://schemas.android.com/apk/res/android}name"
    if name_attribute in node.attrib:
        return node.attrib[name_attribute]
    else:
        return "0"


def sort_tree(node: Element):
    node[:] = sorted(node, key=lambda child: (
        get_sorting_weight(child),
        child.tag,
        get_attribute(child)))
    if node.text is not None:
        node.text = node.text.strip()
    for item in node:
        sort_tree(item)


def register_all_namespaces(filename):
    namespaces = dict([node for _, node in Tree.iterparse(filename, events=['start-ns'])])
    for ns in namespaces:
        Tree.register_namespace(ns, namespaces[ns])


register_all_namespaces(TARGET_MANIFEST_PATH)

# sort xml
tree = Tree.ElementTree(file=TARGET_MANIFEST_PATH)
root: Element = tree.getroot()
sort_tree(root)

output = Tree \
    .tostring(root, encoding="utf-8", method="xml", short_empty_elements=True) \
    .decode()

# write result to file
manifestFile = open(SORTED_MANIFEST_PATH, "w")
manifestFile.write(output)
manifestFile.truncate()

subprocess.run(['tidy', '-config', "tidy.ini", '-o', SORTED_MANIFEST_PATH, SORTED_MANIFEST_PATH])
