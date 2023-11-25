import webbrowser, urllib.parse
import pandas as pd

# digraph with edges only
def getEdges(df):
    
    edges = ""
    for _, row in df.iterrows():
        isRoot = pd.isna(row.iloc[1])
        if not isRoot:
            edges += f'\t"{row.iloc[0]}" -> "{row.iloc[1]}";\n'
    
    return f"digraph {{\n{edges}}}\n"

# digraph with nodes and edges
def getNodes(df):
    
    nodes, edges = "", ""
    for _, row in df.iterrows():
        nodes += f'\tn{row.iloc[0]} [label="{row.iloc[0]}"];\n'
        isRoot = pd.isna(row.iloc[1])
        if not isRoot:
            edges += f"\tn{row.iloc[0]} -> n{row.iloc[1]};\n"
    
    return f"digraph {{\n{nodes}\n{edges}}}\n"

# styled digraph with styled nodes and edges
def getStyles(df):

    nodes, edges = "", ""
    for _, row in df.iterrows():
        isRoot = pd.isna(row.iloc[1])
        nodes += f'\tn{row.iloc[0]} [label="{row.iloc[0]}"'
        if isRoot:
            nodes += f' shape="rect" color="red"'
        nodes += f'];\n'

        if not isRoot:
            edges += f"\tn{row.iloc[0]} -> n{row.iloc[1]}"
            if row.iloc[0] == "BLAKE" or row.iloc[1] == "BLAKE":
                edges += f' [style="dashed"]'
            edges += ';\n'

    return (f"digraph {{\n"
        + '\tgraph [rankdir="BT" bgcolor="#ffffff" splines="ortho"]\n'
        + '\tnode [style="filled" fillcolor="lightblue"]\n'
        + '\tedge [arrowhead="None"]\n\n'
        + f'{nodes}\n{edges}}}\n')

# go to online Graphviz Visual Editor w/ custom graph
# see http://magjac.com/graphviz-visual-editor/
def gotoUrl(dot):
    url = f'http://magjac.com/graphviz-visual-editor/?dot={urllib.parse.quote(dot)}'
    webbrowser.open(url)


df = pd.read_csv("data/employee-manager.csv", header=0).convert_dtypes()

gotoUrl(getEdges(df))
print('Generated DOT graph with edges')

gotoUrl(getNodes(df))
print('Generated DOT graph with nodes and edges')

gotoUrl(getStyles(df))
print('Generated styled DOT graph with styled nodes and edges')
