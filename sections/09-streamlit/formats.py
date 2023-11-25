import pandas as pd

indent = '  '

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
    <object>
      <name>KING</name>
      <children>
        <object>
          <name>BLAKE</name>
          <children>
              <object>
                <name>ALLEN</name>
              </object>
              <object>
                <name>JAMES</name>
              </object>
    ...
    """

    # add <object> and <name>
    indent0 = indent * level
    indent1 = indent0 + indent

    s = '<?xml version="1.0" encoding="utf-8"?>\n' if level == 0 else ''
    s += f"{indent0}<object>\n"
    s += f"{indent1}<name>{node['name']}</name>\n"

    # recursively append the inner children
    if "children" in node:
        s += f"{indent1}<children>\n"
        for child in node["children"]:
            s += getXml(child, level+2)
        s += f"{indent1}</children>\n"

    s += f"{indent0}</object>\n"
    return s

def getYaml(node, level=0, first=False):
    """
    KING
    - BLAKE
      - ALLEN
        JAMES
        MARTIN
    ...
    """

    indent0 = indent * level
    indent1 = indent0 + '  '

    s = f"{node['name']}\n"

    # recursively append the inner children
    if "children" in node:
        first = True
        for child in node["children"]:
            s += f"{indent0}- " if first else indent1
            s += getYaml(child, level+1, first)
            first = False

    return s

def getPath(node, nodes, path=""):
    """
    [{ "id": "KING.JONES.SCOTT.ADAMS" },
    { "id": "KING.BLAKE.ALLEN" },
    { "id": "KING.BLAKE" },
    { "id": "KING.CLARK" },
    ...]
    """

    # append full path to the top of the current node
    path += node["name"] if len(path) == 0 else f'.{node["name"]}'
    nodes.append({ "id": path })

    if "children" in node:
        for child in node["children"]:
            nodes = getPath(child, nodes, path)
    return nodes
