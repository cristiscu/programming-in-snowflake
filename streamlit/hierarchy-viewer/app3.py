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
    # add nodes
    nodes = []
    s = ""
    for row in rows:
        n = f'{str(row[fromCol])}'
        nodes.append(n)
        label = str(row[fromCol]) if displayCol is None else str(row[displayCol])
        s += f'\n\tn{n} [label="{label}"];'

    # add links
    for row in rows:
        if not pd.isna(row[toCol]) and str(row[toCol]) in nodes:
            s += f'\n\tn{str(row[fromCol])} -> n{str(row[toCol])};'

    # add digraph around
    return (f'digraph {{\n'
        + f'\tgraph [rankdir="BT"];\n'
        + f'\tnode [shape="Mrecord"]'
        + f'{s}\n}}')


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

fromCol = st.sidebar.selectbox('Child Column', cols, index=None)
toCol = st.sidebar.selectbox('Parent Column', cols, index=None)
displayCol = st.sidebar.selectbox('Display Column', cols, index=None)

if fromCol is None or toCol is None:
    err = "Select at least one Child field and one Parent field!"
    tabGraph.warning(err)
    tabCode.warning(err)
else:
    fromCol = cols.index(fromCol)
    toCol = cols.index(toCol)
    if displayCol is not None: displayCol = cols.index(displayCol)

    tabGraph.write("This is your generated graph, based on the current sidebar configuration.")
    code = makeGraph(rows, fromCol, toCol, displayCol)
    tabGraph.graphviz_chart(code, use_container_width=True)

    tabCode.write("This is the DOT script code generated for your previous graph.")
    tabCode.code(code, language="dot", line_numbers=True)
