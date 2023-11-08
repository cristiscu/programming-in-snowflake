import json
import streamlit as st
import hierarchical, graphs, connect

# setup page and create tabs
st.set_page_config(layout="wide")
st.title("Hierarchical Data App")
st.caption("Display your parent-child data pairs in a better manner.")

tabSource, tabHierarchy, tabFormat, tabGraph = st.tabs(
    ["Source", "Hierarchy", "Format", "Graph"])

# show source as data frame
with tabSource:

    # from hierarchical_data_app.code schema
    defTableName = "employees"
    tableName = st.text_input("Full table or view name:", value=defTableName)
    st.button("Refresh")
    query = f"select * from {tableName}"
    df = connect.getDataFrame(query)
    if df is None: st.stop()
    st.dataframe(df, use_container_width=True)

# show hierarchy as returned by the Snowflake query
with tabHierarchy:

    # from hierarchical_data_app.code schema
    query = f"select get_tree('{tableName}')"
    query = str(connect.getRows(query)[0][0])
    st.code(query)
    df2 = connect.getDataFrame(query)
    if df2 is None: st.stop()
    st.dataframe(df2, use_container_width=True)

# show in another data format
with tabFormat:

    root = hierarchical.getJson(df, 0, 1)
    sel = st.selectbox("Select a data format:", options=["JSON", "XML", "YAML"])
    if sel == "JSON":
        st.code(json.dumps(root, indent=3), language="json", line_numbers=True)
    elif sel == "XML":
        xml = f'<?xml version="1.0" encoding="utf-8"?>\n{hierarchical.getXml(root)}'
        st.code(xml, language="xml", line_numbers=True)
    elif sel == "YAML":
        st.code(hierarchical.getYaml(root), language="yaml", line_numbers=True)

# show as GraphViz graph
with tabGraph:

    graph = graphs.getEdges(df, 0, 1)
    st.graphviz_chart(graph)
