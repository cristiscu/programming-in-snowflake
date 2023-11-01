import pandas as pd
import streamlit as st
import m3_graphs

st.title("Hierarchical Data Viewer")

filename = "data/employee-manager.csv"
df = pd.read_csv(filename).convert_dtypes()
st.dataframe(df)

graph = m3_graphs.getEdges(df, 0, 1)
st.graphviz_chart(graph)
