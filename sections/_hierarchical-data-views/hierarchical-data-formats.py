import pandas as pd
import json

def getJson(df):
    """
    { "name": "KING",
      "children": [{
         "name": "BLAKE",
         "children": [
            { "name": "ALLEN" },
            { "name": "JAMES" },
            ...
        ]}]
    }
    """

    # collect all nodes
    nodes = {}
    for _, row in df.iterrows():
        name = row.iloc[0]
        nodes[name] = { "name": name }

    # move children under parents, and detect root
    root = None
    for _, row in df.iterrows():
        node = nodes[row.iloc[0]]
        isRoot = pd.isna(row.iloc[1])
        if isRoot: root = node
        else:
            parent = nodes[row.iloc[1]]
            if "children" not in parent: parent["children"] = []
            parent["children"].append(node)

    return root

def getXml(node, level=0):
    """
    <person>
    <name>KING</name>
    <children>
        <person>
            <name>BLAKE</name>
            <children>
                <person>
                <name>ALLEN</name>
                </person>
                <person>
                <name>JAMES</name>
                </person>
    ...
    """

    # add <person> and <name>
    indent = '   '
    s = f"{indent * level}<person>\n"
    s += f"{indent * (level+1)}<name>{node['name']}</name>\n"

    # recursively append the inner children
    if "children" in node:
        s += f"{indent * (level+1)}<children>\n"
        for child in node["children"]:
            s += getXml(child, level+2)
        s += f"{indent * (level+1)}</children>\n"

    return f"{s}{indent * level}</person>\n"

def getYaml(node, level=0, first=False):
    """
    KING
    - BLAKE
    - ALLEN
        JAMES
        MARTIN
    ...
    """

    s = f"{node['name']}\n"

    # recursively append the inner children
    if "children" in node:
        first = True
        for child in node["children"]:
            if first: s += f"{'  ' * level}- "
            else: s += f"{'  ' * level}  "
            s += getYaml(child, level+1, first)
            first = False

    return s

# validate at https://toolkitbay.com/tkb/tool/csv-validator
df = pd.read_csv("data/employee-manager.csv", header=0).convert_dtypes()

# convert and save as JSON
# validate at https://jsonlint.com/
root = getJson(df)
with open("data/employee-manager.json", "w") as f:
    f.writelines(json.dumps(root, indent=3))
print('Generated "data/employee-manager.json" file')

# convert and save as XML
# validate at https://www.liquid-technologies.com/online-xml-validator
xml = f'<?xml version="1.0" encoding="utf-8"?>\n{getXml(root)}'
with open("data/employee-manager.xml", "w") as f:
    f.writelines(xml)
print('Generated "data/employee-manager.xml" file')

# convert and save as YAML
# validate at https://www.yamllint.com/
yaml = getYaml(root)
with open("data/employee-manager.yaml", "w") as f:
    f.writelines(yaml)
print('Generated "data/employee-manager.yaml" file')

