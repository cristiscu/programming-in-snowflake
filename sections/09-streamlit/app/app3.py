import json, urllib.parse
import pandas as pd
import streamlit as st
import streamlit.components.v1 as components
from io import StringIO
import m2_hierarchical, m3_graphs, m4_charts, m5_animated

@st.cache_data(show_spinner="Loading the CSV file...")
def loadFile(filename):
    return pd.read_csv(filename).convert_dtypes()

st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
st.caption("Display your hierarchical data with charts and graphs.")

with st.sidebar:
    # upload CSV file or use default one
    uploaded_file = st.file_uploader(
        "Upload a CSV file", type=["csv"], accept_multiple_files=False)
    
    filename = "data/employee-manager.csv"
    if uploaded_file is not None:
        filename = StringIO(uploaded_file.getvalue().decode("utf-8"))

    df = loadFile(filename)
    cols = list(df.columns)

    # get child and parent column names and indices
    fld_label = st.selectbox('Child Column Name', cols, index=0)
    idx_label = cols.index(fld_label)
    labels = df[df.columns[idx_label]]

    fld_parent = st.selectbox('Parent Column Name', cols, index=1)
    idx_parent = cols.index(fld_parent)
    parents = df[df.columns[idx_parent]]

# create tab control
tabSource, tabFormat, tabGraph, tabChart, tabAnim = st.tabs(
    ["Source", "Format", "Graph", "Chart", "Animated"])

# show source as data frame
with tabSource:
    st.dataframe(df, use_container_width=True)

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
    sel = st.selectbox("Select a Plotly chart type:",
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

# show as D3 animated chart
with tabAnim:
    sel = st.selectbox("Select a D3 chart type:",
        options=["Collapsible Tree", "Linear Dendrogram",
            "Radial Dendrogram", "Network Graph", "Circular Packing"])
    if sel == "Collapsible Tree":
        filename = m5_animated.makeCollapsibleTree(df, idx_label, idx_parent)
    elif sel == "Linear Dendrogram":
        filename = m5_animated.makeLinearDendrogram(df, idx_label, idx_parent)
    elif sel == "Radial Dendrogram":
        filename = m5_animated.makeRadialDendrogram(df, idx_label, idx_parent)
    elif sel == "Network Graph":
        filename = m5_animated.makeNetworkGraph(df, idx_label, idx_parent)
    elif sel == "Circular Packing":
        filename = m5_animated.makeCircularPacking(df, idx_label, idx_parent)

    with open(filename, 'r', encoding='utf-8') as f:
        components.html(f.read(), height=2200, width=1000)
