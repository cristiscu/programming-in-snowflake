import pandas as pd
import streamlit as st
import modules.queries as queries
import modules.graphs as graphs

st.set_page_config(layout="wide")
st.title("Hierarchical Metadata Viewer")
st.caption("Display your Snowflake hierarchical metadata with graphs.")

ops = [
    "Entity-Relationship Diagram",
    "Security (Users and Roles)",
    "Object Dependencies",
    "Data Lineage",
    "Task Workflows",
]
op = st.sidebar.selectbox("Operation", ops, index=None)
st.sidebar.divider()
database, schema = queries.getDatabaseAndSchema()

if op == None:
    st.info("Select an optional database and schema, followed by an operation type.")

# =================================================================
elif op == "Entity-Relationship Diagram":

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
elif op == "Security (Users and Roles)":

    showUsers = st.sidebar.checkbox("Show Users", value=True)
    showRoles = st.sidebar.checkbox("Show Custom Roles", value=True)
    showSystemRoles = st.sidebar.checkbox("Show System-Defined Roles", value=True)
    showGroups = st.sidebar.checkbox("Show User/Role Groups", value=True)
    if not showUsers and not showRoles and not showSystemRoles:
        st.warning("Show at least some users or roles!")
        st.stop()

    tabGraph, tabUsers, tabRoles = st.tabs(["Graph", "Users", "Roles"])
    with tabGraph:
        users, roles = queries.getUsersAndRoles()
        graphs.getGraph(graphs.getUsersAndRoles(users, roles,
            showUsers, showRoles, showSystemRoles, showGroups))

    with tabUsers:
        query = "show users"
        rows = queries.runQuery(query)
        df = pd.DataFrame(rows).convert_dtypes()
        st.code(query)
        st.dataframe(df, use_container_width=True)

    with tabRoles:
        query = "show roles"
        rows = queries.runQuery(query)
        df = pd.DataFrame(rows).convert_dtypes()
        st.code(query)
        st.dataframe(df, use_container_width=True)

# =================================================================
elif op == "Data Lineage":

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

