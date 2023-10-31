import pandas as pd
from io import StringIO
import streamlit as st

# upload a CSV file
@st.cache_data(show_spinner="Loading the CSV file...")
def loadFile(filename):
    df = pd.read_csv(filename).convert_dtypes()
    rows = df.values.tolist()
    cols = tuple(df.columns)
    return df, rows, cols


# returns a DOT graphviz chart
def makeGraph(rows, fromCol, toCol, displayCol):

    # collect all nodes
    nodes = { str(row[fromCol]): str(row[displayCol]) for row in rows}

    # make node links
    graph = ""
    for row in rows:
        if not pd.isna(row[toCol]) and str(row[toCol]) in nodes:
            graph += f'\n\t{nodes[str(row[fromCol])]} -> {nodes[str(row[toCol])]};'

    # return digraph
    graph = f'digraph {{{graph}\n}}'
    return graph


st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")
st.caption("Display your hierarchical data with a graph.")

uploaded_file = st.sidebar.file_uploader(
    "Upload a CSV file", type=["csv"], accept_multiple_files=False)
if uploaded_file is None:
    filename = "../../data/emp.csv"
else:
    filename = StringIO(uploaded_file.getvalue().decode("utf-8"))

df, rows, cols = loadFile(filename)
if len(rows) == 0:
    st.warning("The file is empty!")
    st.stop()

tabSource, tabGraph, tabCode = st.tabs(["Source", "Graph", "Code"])
tabSource.write("The loaded dataset.")
tabSource.dataframe(df, use_container_width=True)

fromCol = cols.index(st.sidebar.selectbox('Child Column', cols))
displayCol = cols.index(st.sidebar.selectbox('Display Column', cols))
toCol = cols.index(st.sidebar.selectbox('Parent Column', cols))

tabGraph.write("This is your generated graph, based on the current sidebar configuration.")
code = makeGraph(rows, fromCol, toCol, displayCol)
tabGraph.graphviz_chart(code, use_container_width=True)

tabCode.write("This is the DOT script code generated for your previous graph.")
tabCode.code(code, language="dot", line_numbers=True)
