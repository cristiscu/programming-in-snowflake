import json
import streamlit as st
import m2_hierarchical, m3_graphs, m4_charts, m6_connect

# log messages (logger) + trace events (telemetry)
import logger
from snowflake import telemetry

# setup page and create tabs
st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
st.caption("Display your hierarchical data with charts and graphs.")

tabSource, tabHierarchy, tabFormat, tabGraph, tabChart = st.tabs(
    ["Source", "Hierarchy", "Format", "Graph", "Chart"])

# show source as data frame
with tabSource:
    defTableName = "hierarchy_data_viewer.public.employees"
    #defTableName = "employees.public.employee_manager2"
    tableName = st.text_input("Table or view full name:", value=defTableName)
    st.button("Refresh")
    query = f"select * from {tableName}"
    df = m6_connect.getDataFrame(query)
    if df is None: st.stop()
    st.dataframe(df, use_container_width=True)

# show hierarchy as returned by the Snowflake query
with tabHierarchy:
    query = f"""with recursive cte (level, name, child, parent, path) as (
  select 1, $1, $1, $2, ' -> ' || $1
  from {tableName} where $2 is null
  union all
  select m.level + 1, repeat('  ', level) || e.$1,
    e.$1, e.$2, path || ' -> ' || e.$1
  from {tableName} e join cte m on e.$2 = m.child)
select name, path from cte order by path;
"""
    df2 = m6_connect.getDataFrame(query)
    if df2 is None: st.stop()
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
    elif sel == "YAML":
        st.code(m2_hierarchical.getYaml(root), language="yaml", line_numbers=True)

# show as GraphViz graph
with tabGraph:
    graph = m3_graphs.getEdges(df, idx_label, idx_parent)
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
    elif sel == "Sankey":
        fig = m4_charts.makeSankey(labels, parents)
    st.plotly_chart(fig, use_container_width=True)

