import pandas as pd
import streamlit as st
import modules.queries as queries
import modules.graphs as graphs

st.set_page_config(
    page_title="Entity-Relationship Diagram",
    page_icon="📄",
    layout="wide")
st.title("Entity-Relationship Diagram")
st.caption("Display an ER diagram per schema, with relationships between tables.")
st.sidebar.title("Entity-Relationship Diagram")

database, schema = queries.getDatabaseAndSchema()
if database is None or schema is None:
    st.warning("Select a database and a schema!")
    st.stop()

query, rows = queries.getFKDeps(database, schema)
if rows is None: st.stop()
df = pd.DataFrame(rows).convert_dtypes()
if df.size == 0: st.warning("No data!"); st.stop()

tabGraph, tabMetadata = st.tabs(["Graph", "Metadata"])
with tabGraph:
    graphs.getGraph(graphs.getFkDeps(rows))

with tabMetadata:
    st.code(query)
    st.dataframe(df.head(1000), use_container_width=True)
    st.write("Max 1,000 rows are displayed here.")
