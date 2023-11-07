# after "pip install pyvis"
from pyvis.network import Network
import os, json
import pandas as pd

def makeCollapsibleTree(df, idx_label, idx_parent):
    return _makeTree("collapsible-tree", df, idx_label, idx_parent)

def makeLinearDendrogram(df, idx_label, idx_parent):
    return _makeTree("linear-dendrogram", df, idx_label, idx_parent)

def _makeTree(template, df, idx_label, idx_parent):

    root = _getTree(df, idx_label, idx_parent)

    # create HTML file from template customized with our JSON
    with open(f"animated/templates/{template}.html", "r") as file:
        content = file.read()
    filename = f'animated/{template}.html'
    with open(filename, "w") as file:
        file.write(content.replace('"{{data}}"', json.dumps(root, indent=4)))
    return os.path.abspath(filename)

def _getTree(df, idx_label, idx_parent):
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
        node = nodes[row.iloc[idx_label]]
        isRoot = pd.isna(row.iloc[idx_parent])
        if isRoot: root = node
        else:
            parent = nodes[row.iloc[idx_parent]]
            if "children" not in parent: parent["children"] = []
            parent["children"].append(node)

    return root

def makeRadialDendrogram(df, idx_label, idx_parent):

    nodes = _getPath(df, idx_label, idx_parent)

    # create HTML file from template customized with our JSON array
    with open(f"animated/templates/radial-dendrogram.html", "r") as file:
        content = file.read()
    filename = 'animated/radial-dendrogram.html'
    with open(filename, "w") as file:
        file.write(content.replace('"{{data}}"', json.dumps(nodes, indent=4)))
    return os.path.abspath(filename)

def _getPath(df, idx_label, idx_parent):
    """
    [{ "id": "KING.JONES.SCOTT.ADAMS" },
    { "id": "KING.BLAKE.ALLEN" },
    { "id": "KING.BLAKE" },
    { "id": "KING.CLARK" },
    ...]
    """

    # add nodes (to a local map)
    nodes, root = {}, None
    for _, row in df.iterrows():
        name = row.iloc[idx_label]
        node = { "id": name, "name": name }
        if not pd.isna(row.iloc[1]): node["parent"] = row.iloc[idx_parent]
        else: root = node
        nodes[name] = node

    # add node name prefixes
    for key in nodes:
        node = nodes[key]
        nodeCrt = node
        while node is not root:
            parent = nodes[node["parent"]]
            nodeCrt["id"] = f'{parent["name"]}.{nodeCrt["id"]}'
            node = parent

    return [{ "id": node["id"] } for node in nodes.values()]

def makeNetworkGraph(df, idx_label, idx_parent):

    data = Network(notebook=True, heading='')
    data.barnes_hut(
        gravity=-80000,
        central_gravity=0.3,
        spring_length=10.0,
        spring_strength=1.0,
        damping=0.09,
        overlap=0)

    for _, row in df.iterrows():
        src = str(row.iloc[idx_label])
        dst = str(row.iloc[idx_parent])
        data.add_node(src)
        data.add_node(dst)
        data.add_edge(src, dst)

    # set node size to number of child nodes
    map = data.get_adj_list()
    for node in data.nodes:
        node["value"] = len(map[node["id"]])

    filename = f'animated/network-graph.html'
    data.show(filename)
    return os.path.abspath(filename)
