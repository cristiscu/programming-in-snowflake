from pyvis.network import Network
import os, json, webbrowser
import pandas as pd

def makeCollapsibleTree(df):
    return _makeTree("collapsible-tree", df)

def makeLinearDendrogram(df):
    return _makeTree("linear-dendrogram", df)

def makeCircularPacking(df):
    return _makeTree("circular-packing", df)

def _makeTree(template, df):

    root = _getTree(df)

    # create HTML file from template customized with our JSON
    with open(f"animated/templates/{template}.html", "r") as file:
        content = file.read()
    filename = f'animated/{template}.html'
    with open(filename, "w") as file:
        file.write(content.replace('"{{data}}"', json.dumps(root, indent=4)))
    return os.path.abspath(filename)

def _getTree(df):
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

def makeRadialDendrogram(df):

    nodes = _getPath(df)

    # create HTML file from template customized with our JSON array
    with open(f"animated/templates/radial-dendrogram.html", "r") as file:
        content = file.read()
    filename = 'animated/radial-dendrogram.html'
    with open(filename, "w") as file:
        file.write(content.replace('"{{data}}"', json.dumps(nodes, indent=4)))
    return os.path.abspath(filename)

def _getPath(df):
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
        name = row.iloc[0]
        node = { "id": name, "name": name }
        if not pd.isna(row.iloc[1]): node["parent"] = row.iloc[1]
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

def makeNetworkGraph(df):

    data = Network(notebook=True, heading='')
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

    filename = f'animated/network-graph.html'
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

filename = makeCircularPacking(df)
print('Generated Circular Packing')
webbrowser.open(filename)
