import pandas as pd
import streamlit as st
import modules.queries as queries
import modules.graphs as graphs

st.set_page_config(
    page_title="Object Dependencies",
    page_icon="📄",
    layout="wide")
st.title("Object Dependencies")
st.caption("Display dependency relationships between database objects.")
st.sidebar.title("Object Dependencies")

database, schema = queries.getDatabaseAndSchema()

query, rows = queries.getObjDeps(database, schema)
if rows is None: st.stop()
df = pd.DataFrame(rows).convert_dtypes()
if df.size == 0: st.warning("No data!"); st.stop()

tabGraph, tabMetadata = st.tabs(["Graph", "Metadata"])
with tabGraph:
    graphs.getGraph(graphs.getObjDeps(
        rows, database is not None, schema is not None))

with tabMetadata:
    st.code(query)
    st.dataframe(df.head(1000), use_container_width=True)
    st.write("Max 1,000 rows are displayed here.")
