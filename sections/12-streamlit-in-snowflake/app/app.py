import json
import streamlit as st
import modules.graphs as graphs
import modules.formats as formats
import modules.charts as charts
import modules.utils as utils

# log messages (logger) + trace events (telemetry)
import logging
#from snowflake import telemetry

# setup page and create tabs
st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
st.caption("Display your hierarchical data with charts and graphs.")

tabSource, tabHierarchy, tabFormat, tabGraph, tabChart = st.tabs(
    ["Source", "Hierarchy", "Format", "Graph", "Chart"])

# show source as data frame
with tabSource:
    defTableName = "hierarchy_data_viewer.public.employees"
    tableName = st.text_input("Enter full name of a table or view:", value=defTableName)
    st.button("Refresh")

    query = f"select * from {tableName}"
    df_orig = utils.getDataFrame(query)
    if df_orig is None: st.stop()
    st.dataframe(df_orig, use_container_width=True)
    cols = list(df_orig.columns)

    child = st.sidebar.selectbox("Child Column Name", cols, index=0)
    parent = st.sidebar.selectbox("Parent Column Name", cols, index=1)
    df = df_orig[[child, parent]]

# show name and path as returned by the Snowflake query
with tabHierarchy:
    query = f"call hierarchy_data_viewer.public.show_tree('{tableName}')"
    df_path = utils.getDataFrame(query)
    if df_path is None: st.stop()
    st.dataframe(df_path, use_container_width=True)

# show in another data format
with tabFormat:
    sel = st.selectbox(
        "Select a data format:",
        options=["JSON", "XML", "YAML", "JSON Path"])

    root = formats.getJson(df)
    if sel == "JSON":
        jsn = json.dumps(root, indent=2)
        st.code(jsn, language="json", line_numbers=True)
    elif sel == "XML":
        xml = formats.getXml(root)
        st.code(xml, language="xml", line_numbers=True)
    elif sel == "YAML":
        yaml = formats.getYaml(root)
        st.code(yaml, language="yaml", line_numbers=True)
    elif sel == "JSON Path":
        jsn = json.dumps(formats.getPath(root, []), indent=2)
        st.code(jsn, language="json", line_numbers=True)

# show as GraphViz graph
with tabGraph:
    graph = graphs.getEdges(df)
    try: st.link_button("Visualize Online", graphs.getUrl(graph))
    except: pass
    st.graphviz_chart(graph)

# show as Plotly chart
with tabChart:
    labels = df[df.columns[0]]
    parents = df[df.columns[1]]

    sel = st.selectbox(
        "Select a chart type:",
        options=["Treemap", "Icicle", "Sunburst", "Sankey"])
    if sel == "Treemap":
        fig = charts.makeTreemap(labels, parents)
    elif sel == "Icicle":
        fig = charts.makeIcicle(labels, parents)
    elif sel == "Sunburst":
        fig = charts.makeSunburst(labels, parents)
    elif sel == "Sankey":
        fig = charts.makeSankey(labels, parents)
    st.plotly_chart(fig, use_container_width=True)
