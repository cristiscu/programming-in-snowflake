import pandas as pd
import streamlit as st
import graphviz

st.title("Hierarchical Data Viewer")

# load data file and highlight columns
df = pd.read_csv("../../data/emp.csv").convert_dtypes()
rows = df.values.tolist()
df = df.style.applymap(
    lambda s: 'background-color: %s' % 'yellow',
    subset=pd.IndexSlice[:, ['EMPNO', 'ENAME', 'MGR']])
st.dataframe(df)

# collect all nodes
nodes = { str(row[0]): str(row[1]) for row in rows }

# make and show GraphViz graph
graph = graphviz.Digraph()
for row in rows:
    if not pd.isna(row[3]) and str(row[3]) in nodes:
        graph.edge(nodes[str(row[0])], nodes[str(row[3])])

st.graphviz_chart(graph)
