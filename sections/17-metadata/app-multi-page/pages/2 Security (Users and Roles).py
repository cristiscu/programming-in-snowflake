import pandas as pd
import streamlit as st
import modules.queries as queries
import modules.graphs as graphs

st.set_page_config(
    page_title="Security (Users and Roles)",
    page_icon="📄",
    layout="wide")
st.title("Security (Users and Roles)")
st.caption("Display user, roles, and the role hierarchy.")
st.sidebar.title("Security (Users and Roles)")

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
