import json, os
import streamlit as st
import streamlit.components.v1 as components
import pandas as pd
from io import StringIO
import modules.graphs as graphs
import modules.formats as formats
import modules.charts as charts
import modules.animated as animated
import modules.utils as utils

st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
st.caption("Display your hierarchical data with charts and graphs.")

@st.cache_data(show_spinner="Loading the CSV file...")
def loadFile(filename):
    print(f"Loading {filename}...")
    return pd.read_csv(filename).convert_dtypes()

with st.sidebar:
    uploaded_file = st.file_uploader(
        "Upload a CSV file", type=["csv"], accept_multiple_files=False)
    
    path = os.path.dirname(__file__)
    filename = utils.getFullPath("data/employee-manager.csv")
    if uploaded_file is not None:
        filename = StringIO(uploaded_file.getvalue().decode("utf-8"))

    df_orig = loadFile(filename)
    cols = list(df_orig.columns)

    child = st.selectbox("Child Column Name", cols, index=0)
    parent = st.selectbox("Parent Column Name", cols, index=1)
    df = df_orig[[child, parent]]

tabSource, tabFormat, tabGraph, tabChart, tabAnim = st.tabs(
    ["Source", "Format", "Graph", "Chart", "Animated"])

with tabSource:
    st.dataframe(df_orig, use_container_width=True)

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

with tabGraph:
    graph = graphs.getEdges(df)
    url = graphs.getUrl(graph)
    st.link_button("Visualize Online", url)
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

# show as D3 animated chart
with tabAnim:
    sel = st.selectbox(
        "Select a D3 chart type:",
        options=["Collapsible Tree", "Linear Dendrogram",
            "Radial Dendrogram", "Network Graph"])
    if sel == "Collapsible Tree":
        filename = animated.makeCollapsibleTree(df)
    elif sel == "Linear Dendrogram":
        filename = animated.makeLinearDendrogram(df)
    elif sel == "Radial Dendrogram":
        filename = animated.makeRadialDendrogram(df)
    elif sel == "Network Graph":
        filename = animated.makeNetworkGraph(df)

    with open(filename, 'r', encoding='utf-8') as f:
        components.html(f.read(), height=2200, width=1000)
