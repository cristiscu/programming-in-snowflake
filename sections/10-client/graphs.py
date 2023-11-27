import urllib.parse
import pandas as pd

# digraph with edges only
def getEdges(df):
    
    edges = ""
    for _, row in df.iterrows():
        isRoot = pd.isna(row.iloc[1])
        if not isRoot:
            edges += f'\t"{row.iloc[0]}" -> "{row.iloc[1]}";\n'
    
    return f"digraph {{\n{edges}}}\n"

# get URL to Graphviz Visual Editor, w/ custom graph
def getUrl(dot):
    return f'http://magjac.com/graphviz-visual-editor/?dot={urllib.parse.quote(dot)}'
