# after "pip install pyvis"
from pyvis.network import Network
import os, json, webbrowser
import pandas as pd

def makeCollapsibleTree(df): return _makeTree("collapsible-tree", df)
def makeLinearDendrogram(df): return _makeTree("linear-dendrogram", df)

def _makeTree(template, df):
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

    # create HTML file from template customized with our JSON
    with open(f"d3/templates/{template}.html", "r") as file:
        content = file.read()
    filename = f'd3/{template}.html'
    with open(filename, "w") as file:
        file.write(content.replace('"{{data}}"', json.dumps(root, indent=4)))
    return os.path.abspath(filename)

def makeRadialDendrogram(df):
    """
    [{ "id": "KING.JONES.SCOTT.ADAMS" },
    { "id": "KING.BLAKE.ALLEN" },
    { "id": "KING.BLAKE" },
    { "id": "KING.CLARK" },
    ...]
    """

    dummy_name = "_"
    root = { "id": dummy_name, "name": dummy_name }
    nodes = {}
    nodes[dummy_name] = root

    # add nodes (to a local map)
    for _, row in df.iterrows():
        nFrom = row.iloc[2]
        name = row.iloc[0]
        node = { "id": name, "name": name }
        nodes[nFrom] = node
        if not pd.isna(row.iloc[1]): node["parentId"] = row.iloc[3]

    # count top nodes
    topNodes = 0
    for key in nodes:
        node = nodes[key]
        if node is not root \
            and ("parentId" not in node \
            or node["parentId"] not in nodes):
            node["parentId"] = dummy_name
            topNodes += 1

    # add node name prefixes
    for key in nodes:
        node = nodes[key]
        nodeCrt = node
        while node is not root:
            parentId = node["parentId"]
            nodeP = nodes[parentId]
            if nodeP is not root or topNodes > 1:
                nodeCrt["id"] = f'{nodeP["name"]}.{nodeCrt["id"]}'
            node = nodeP

    # create final array
    nodesA = []
    for node in nodes.values():
        obj = { "id": node["id"] }
        nodesA.append(obj)

    # remove dummy node
    if topNodes == 1:
        obj = next((n for n in nodesA if n["id"] == dummy_name), None)
        nodesA.remove(obj)

    # create HTML file from template customized with our JSON array
    with open(f"d3/templates/radial-dendrogram.html", "r") as file:
        content = file.read()
    filename = 'd3/radial-dendrogram.html'
    with open(filename, "w") as file:
        file.write(content.replace('"{{data}}"', json.dumps(nodesA, indent=4)))
    return os.path.abspath(filename)

def makeNetworkGraph(df):

    data = Network(height="600px", width="100%", notebook=True, heading='')
    data.barnes_hut(
        gravity=-80000,
        central_gravity=0.3,
        spring_length=10.0,
        spring_strength=1.0,
        damping=0.09,
        overlap=0)

    for _, row in df.iterrows():
        src = str(row.iloc[0])
        dst = str(row.iloc[1])
        data.add_node(src)
        data.add_node(dst)
        data.add_edge(src, dst)

    # set node size to number of child nodes
    map = data.get_adj_list()
    for node in data.nodes:
        node["value"] = len(map[node["id"]])

    filename = f'd3/network-graph.html'
    data.show(filename)
    return os.path.abspath(filename)

df = pd.read_csv("data/employee-manager.csv", header=0).convert_dtypes()

filename = makeCollapsibleTree(df)
print('Generated Collapsible Tree')
webbrowser.open(filename)

filename = makeLinearDendrogram(df)
print('Generated Linear Dendrogram')
webbrowser.open(filename)

filename = makeRadialDendrogram(df)
print('Generated Radial Dendrogram')
webbrowser.open(filename)

filename = makeNetworkGraph(df)
print('Generated Network Chart')
webbrowser.open(filename)
