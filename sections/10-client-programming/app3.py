import json, urllib.parse, os, configparser
import pandas as pd
import streamlit as st
import streamlit.components.v1 as components
import m2_hierarchical, m3_graphs, m4_charts, m5_animated
import snowflake.connector

# customize with your own Snowflake connection parameters
@st.cache_resource
def getConnection():
    parser = configparser.ConfigParser()
    parser.read(os.path.join(os.path.expanduser('~'), ".snowsql/config"))
    section = "connections.demo_conn"

    return snowflake.connector.connect(
        account=parser.get(section, "accountname"),
        user=parser.get(section, "username"),
        password=os.environ['SNOWSQL_PWD'],
        database='EMPLOYEES',
        schema='PUBLIC')

@st.cache_data(show_spinner="Executing the Snowflake query...")
def getDataFrame(query, columns):
    cur = getConnection().cursor()
    cur.execute(query)
    rows = cur.fetchall()
    return pd.DataFrame(rows, columns=columns)


# setup page and create tabs
st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
st.caption("Display your hierarchical data with charts and graphs.")

tabSource, tabHierarchy, tabFormat, tabGraph, tabChart, tabAnim = st.tabs(
    ["Source", "Hierarchy", "Format", "Graph", "Chart", "Animated"])

# show source as data frame
with tabSource:
    query = "select * from employee_manager2"
    df = getDataFrame(query, ["Child", "Parent"])
    st.dataframe(df, use_container_width=True)

# show hierarchy as returned by the Snowflake query
with tabHierarchy:
    query = "select name, path from employee_hierarchy2 order by path"
    df2 = getDataFrame(query, ["Hierarchy", "Path"])
    st.dataframe(df2, use_container_width=True)

# the rest is like before!
# =============================================================

idx_label, idx_parent = 0, 1
labels = df[df.columns[idx_label]]
parents = df[df.columns[idx_parent]]

# show in another data format
with tabFormat:
    sel = st.selectbox(
        "Select a data format:",
        options=["JSON", "XML", "YAML"])

    root = m2_hierarchical.getJson(df, idx_label, idx_parent)
    if sel == "JSON":
        st.code(json.dumps(root, indent=3), language="json", line_numbers=True)
    elif sel == "XML":
        xml = f'<?xml version="1.0" encoding="utf-8"?>\n{m2_hierarchical.getXml(root)}'
        st.code(xml, language="xml", line_numbers=True)
    else:
        st.code(m2_hierarchical.getYaml(root), language="yaml", line_numbers=True)

# show as GraphViz graph
with tabGraph:
    graph = m3_graphs.getEdges(df, idx_label, idx_parent)
    url = f'http://magjac.com/graphviz-visual-editor/?dot={urllib.parse.quote(graph)}'
    st.link_button("Visualize Online", url)
    st.graphviz_chart(graph)

# show as Plotly chart
with tabChart:
    sel = st.selectbox(
        "Select a chart type:",
        options=["Treemap", "Icicle", "Sunburst", "Sankey"])
    if sel == "Treemap":
        fig = m4_charts.makeTreemap(labels, parents)
    elif sel == "Icicle":
        fig = m4_charts.makeIcicle(labels, parents)
    elif sel == "Sunburst":
        fig = m4_charts.makeSunburst(labels, parents)
    else:
        fig = m4_charts.makeSankey(labels, parents)
    st.plotly_chart(fig, use_container_width=True)

# show as D3 animated chart
with tabAnim:
    sel = st.selectbox(
        "Select a D3 chart type:",
        options=["Collapsible Tree", "Linear Dendrogram",
            "Radial Dendrogram", "Network Graph"])
    if sel == "Collapsible Tree":
        filename = m5_animated.makeCollapsibleTree(df, idx_label, idx_parent)
    elif sel == "Linear Dendrogram":
        filename = m5_animated.makeLinearDendrogram(df, idx_label, idx_parent)
    elif sel == "Radial Dendrogram":
        filename = m5_animated.makeRadialDendrogram(df, idx_label, idx_parent)
    else:
        filename = m5_animated.makeNetworkGraph(df, idx_label, idx_parent)

    with open(filename, 'r', encoding='utf-8') as f:
        components.html(f.read(), height=2200, width=1000)
