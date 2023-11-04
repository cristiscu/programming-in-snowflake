import pandas as pd
import streamlit as st
import utils, queries, graphs

st.set_page_config(layout="wide")
st.title("Hierarchical Metadata Viewer")
st.caption("Display your Snowflake hierarchical metadata with graphs.")

ops = [
    "Entity-Relationship Diagram",
    "Users and Roles",
    "Object Dependencies",
    "Data Lineage",
    "Tag Lineage",
    "Task Workflows",
]
op = st.sidebar.selectbox("Operation", ops)
st.sidebar.divider()

# =================================================================
if op == "Entity-Relationship Diagram":

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

# =================================================================
elif op == "Users and Roles":

    showUsers = st.sidebar.checkbox("Show Users", value=True)
    showSystem = st.sidebar.checkbox("Show System Roles", value=True)

    tabGraph, tabUsers, tabRoles = st.tabs(["Graph", "Users", "Roles"])
    with tabGraph:
        users, roles = queries.getUsersAndRoles()
        graphs.getGraph(graphs.getUsersAndRoles(users, roles, showSystem, showUsers))

    with tabUsers:
        query = "show users"
        rows = utils.runQuery(query)
        df = pd.DataFrame(rows).convert_dtypes()
        st.code(query)
        st.dataframe(df, use_container_width=True)

    with tabRoles:
        query = "show roles"
        rows = utils.runQuery(query)
        df = pd.DataFrame(rows).convert_dtypes()
        st.code(query)
        st.dataframe(df, use_container_width=True)

# =================================================================
elif op == "Tag Lineage":
    pass

# =================================================================
elif op == "Data Lineage":

    database, schema = queries.getDatabaseAndSchema()
    #if database is None or schema is None:
    #    st.warning("Select a database and a schema!")
    #    st.stop()

    query, rows = queries.getDataLineage(database, schema)
    if rows is None: st.stop()
    df = pd.DataFrame(rows).convert_dtypes()
    if df.size == 0: st.warning("No data!"); st.stop()

    tabGraph, tabMetadata = st.tabs(["Graph", "Metadata"])
    with tabGraph:
        graphs.getGraph(graphs.getDataLineage(rows))

    with tabMetadata:
        st.code(query)
        st.dataframe(df.head(1000), use_container_width=True)
        st.write("Max 1,000 rows are displayed here.")

# =================================================================
elif op == "Object Dependencies":

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

# =================================================================
elif op == "Task Workflows":

    database, schema = queries.getDatabaseAndSchema()

    query, rows = queries.getTasks(database, schema)
    if rows is None: st.stop()
    df = pd.DataFrame(rows).convert_dtypes()
    if df.size == 0: st.warning("No data!"); st.stop()

    tabGraph, tabMetadata = st.tabs(["Graph", "Metadata"])
    with tabGraph:
        graphs.getGraph(graphs.getAllTasks(
            rows, database is not None, schema is not None))

    with tabMetadata:
        st.code(query)
        st.dataframe(df.head(1000), use_container_width=True)
        st.write("Max 1,000 rows are displayed here.")

