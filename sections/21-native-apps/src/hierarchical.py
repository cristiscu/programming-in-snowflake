import pandas as pd

def getJson(df, idx_label, idx_parent):
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
        name = row.iloc[idx_label]
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
    indent = '   '
    s = f"{indent * level}<object>\n"
    s += f"{indent * (level+1)}<name>{node['name']}</name>\n"

    # recursively append the inner children
    if "children" in node:
        s += f"{indent * (level+1)}<children>\n"
        for child in node["children"]:
            s += getXml(child, level+2)
        s += f"{indent * (level+1)}</children>\n"

    return f"{s}{indent * level}</object>\n"

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
