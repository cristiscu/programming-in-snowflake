import webbrowser, urllib.parse
import pandas as pd

# digraph with edges only
def getEdges(df, idx_label, idx_parent):
    
    edges = ""
    for _, row in df.iterrows():
        isRoot = pd.isna(row.iloc[idx_parent])
        if not isRoot:
            edges += f"\t{row.iloc[idx_label]} -> {row.iloc[idx_parent]};\n"
    
    return f"digraph {{\n{edges}}}\n"

# digraph with nodes and edges
def getNodes(df, idx_label, idx_parent, idx_id, idx_parent_id):
    
    nodes, edges = "", ""
    for _, row in df.iterrows():
        nodes += f'\tn{row.iloc[idx_id]} [label="{row.iloc[idx_label]}"];\n'
        isRoot = pd.isna(row.iloc[idx_parent])
        if not isRoot:
            edges += f"\tn{row.iloc[idx_id]} -> n{row.iloc[idx_parent_id]};\n"
    
    return f"digraph {{\n{nodes}\n{edges}}}\n"

# styled digraph with styled nodes and edges
def getStyles(df, idx_label, idx_parent, idx_id, idx_parent_id):

    nodes, edges = "", ""
    for _, row in df.iterrows():
        isRoot = pd.isna(row.iloc[idx_parent])
        nodes += f'\tn{row.iloc[idx_id]} [label="{row.iloc[idx_label]}"'
        if isRoot:
            nodes += f' shape="rect" color="red"'
        nodes += f'];\n'

        if not isRoot:
            edges += f"\tn{row.iloc[idx_id]} -> n{row.iloc[idx_parent_id]}"
            if row.iloc[idx_label] == "BLAKE" or row.iloc[idx_parent] == "BLAKE":
                edges += f' [style="dashed"]'
            edges += ';\n'

    return (f"digraph {{\n"
        + '\tgraph [rankdir="BT" bgcolor="#ffffff" splines="ortho"]\n'
        + '\tnode [style="filled" fillcolor="lightblue"]\n'
        + '\tedge [arrowhead="None"]\n\n'
        + f'{nodes}\n{edges}}}\n')

# go to online Graphviz Visual Editor w/ custom graph
def gotoUrl(dot):
    url = f'http://magjac.com/graphviz-visual-editor/?dot={urllib.parse.quote(dot)}'
    webbrowser.open(url)


df = pd.read_csv("data/employee-manager.csv", header=0).convert_dtypes()

gotoUrl(getEdges(df, 0, 1))
print('Generated DOT graph with edges')

gotoUrl(getNodes(df, 0, 1, 2, 3))
print('Generated DOT graph with nodes and edges')

gotoUrl(getStyles(df, 0, 1, 2, 3))
print('Generated styled DOT graph with styled nodes and edges')
