from pyvis.network import Network
import os, json
import modules.formats as formats
import modules.utils as utils

def makeCollapsibleTree(df):
    return _makeTree("collapsible-tree", df)

def makeLinearDendrogram(df):
    return _makeTree("linear-dendrogram", df)

def makeCircularPacking(df):
    return _makeTree("circular-packing", df)

def _makeTree(template, df):

    root = formats.getJson(df)

    # create HTML file from template customized with our JSON
    with open(utils.getFullPath(f"animated/templates/{template}.html"), "r") as file:
        content = file.read()
        
    filename = utils.getFullPath(f'animated/{template}.html')
    with open(filename, "w") as file:
        file.write(content.replace('"{{data}}"', json.dumps(root, indent=4)))
    return os.path.abspath(filename)

def makeRadialDendrogram(df):

    path = formats.getPath(formats.getJson(df), [])

    # create HTML file from template customized with our JSON array
    with open(utils.getFullPath("animated/templates/radial-dendrogram.html"), "r") as file:
        content = file.read()
    content = content.replace('"{{data}}"', json.dumps(path, indent=2))

    filename = utils.getFullPath("animated/radial-dendrogram.html")
    with open(filename, "w") as file:
        file.write(content)
    return filename

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

    filename = utils.getFullPath("animated/network-graph.html")
    data.show(filename)
    return os.path.abspath(filename)
