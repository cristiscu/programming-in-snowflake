import pandas as pd
import streamlit as st

# returns a DOT graphviz chart
def makeGraph(rows, fromCol, toCol, displayCol):
    nodes = []
    s = ""

    # add nodes
    for row in rows:
        n = f'{str(row[fromCol])}'
        nodes.append(n)
        label = str(row[fromCol]) if displayCol is None else str(row[displayCol])
        s += f'\n\tn{n} [label="{label}"];'

    # add links
    for row in rows:
        if not pd.isna(row[toCol]) and str(row[toCol]) in nodes:
            s += f'\n\tn{str(row[fromCol])} -> n{str(row[toCol])};'

    # add digraph around
    return f'digraph {{\n\tgraph [rankdir="BT"];\n\tnode [shape="Mrecord"]{s}\n}}'


st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
tabSource, tabGraph, tabCode = st.tabs(["Source", "Graph", "Code"])

df = pd.read_csv("../../data/emp.csv").convert_dtypes()
rows = df.values.tolist()
cols = tuple(df.columns)
tabSource.dataframe(df, use_container_width=True)

fromCol = st.sidebar.selectbox('Child Column', cols, index=None)
toCol = st.sidebar.selectbox('Parent Column', cols, index=None)
displayCol = st.sidebar.selectbox('Display Column', cols, index=None)

if fromCol is None or toCol is None:
    err = "Select at least one Child field and one Parent field!"
    tabGraph.warning(err)
    tabCode.warning(err)
else:
    fromCol = cols.index(fromCol)
    toCol = cols.index(toCol)
    if displayCol is not None: displayCol = cols.index(displayCol)

    code = makeGraph(rows, fromCol, toCol, displayCol)
    tabGraph.graphviz_chart(code, use_container_width=True)
    tabCode.code(code, language="dot", line_numbers=True)
