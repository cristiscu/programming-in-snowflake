import pandas as pd
import streamlit as st

# returns a DOT graphviz chart
def makeGraph(rows, fromCol, toCol, displayCol):

    # collect all nodes
    nodes = { str(row[fromCol]): str(row[displayCol]) for row in rows}

    # make node links
    graph = ""
    for row in rows:
        if not pd.isna(row[toCol]) and str(row[toCol]) in nodes:
            graph += f'\n\t{nodes[str(row[fromCol])]} -> {nodes[str(row[toCol])]};'

    # return digraph
    graph = f'digraph {{{graph}\n}}'
    return graph


st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
tabSource, tabGraph, tabCode = st.tabs(["Source", "Graph", "Code"])

df = pd.read_csv("../../data/emp.csv").convert_dtypes()
rows = df.values.tolist()
cols = tuple(df.columns)
tabSource.dataframe(df, use_container_width=True)

fromCol = cols.index(st.sidebar.selectbox('Child Column', cols))
displayCol = cols.index(st.sidebar.selectbox('Display Column', cols))
toCol = cols.index(st.sidebar.selectbox('Parent Column', cols))

code = makeGraph(rows, fromCol, toCol, displayCol)
tabGraph.graphviz_chart(code, use_container_width=True)
tabCode.code(code, language="dot", line_numbers=True)
