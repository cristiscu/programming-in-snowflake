import configparser, os
# import graphviz
import pandas as pd
import streamlit as st
from snowflake.snowpark import Session
from snowflake.snowpark.context import get_active_session

# allows Snowflake connection from the account or locally
def getSession():
    try:
        return get_active_session()
    except:
        parser = configparser.ConfigParser()
        parser.read(os.path.join(os.path.expanduser('~'), ".snowsql/config"))
        section = "connections.demo_conn"
        pars = {
            "account": parser.get(section, "accountname"),
            "user": parser.get(section, "username"),
            "password": os.environ['SNOWSQL_PWD']
        }
        return Session.builder.configs(pars).create()


# run the SQL query, when changed
@st.cache_data(show_spinner="Executing the SQL query...")
def runQuery(query):
    dfs = getSession().sql(query)
    rows = dfs.collect()
    df = pd.DataFrame(rows).convert_dtypes()
    cols = tuple(dfs.columns)
    return df, rows, cols


# returns a DOT graphviz chart
def makeGraph(rows, fromCol, toCol, displayCol):

    # collect all nodes
    nodes = { str(row[fromCol]): str(row[displayCol]) for row in rows}

    # make node links
    graph = "" # graphviz.Digraph()
    for row in rows:
        if not pd.isna(row[toCol]) and str(row[toCol]) in nodes:
            graph += f'\n\t{nodes[str(row[fromCol])]} -> {nodes[str(row[toCol])]};'
            # graph.edge(nodes[str(row[fromCol])], nodes[str(row[toCol])])

    # return digraph
    graph = f'digraph {{{graph}\n}}'
    return graph


st.set_page_config(layout="wide")
st.title("Hierarchical Data Viewer")

tabSource, tabGraph, tabCode = st.tabs(["Source", "Graph", "Code"])

sql = "select * from hierarchy_viewer.public.emp;"
query = tabSource.text_area(label="Enter the SQL query to execute:", value=sql)
if query not in st.session_state or st.session_state["query"] != query:
    if tabSource.button("Run"):
        st.session_state["query"] = query

df, rows, cols = runQuery(query)
if len(rows) == 0:
    tabSource.warning("There is no data!")
    st.stop()

tabSource.dataframe(rows, use_container_width=True)

fromCol = cols.index(st.sidebar.selectbox('Child Column', cols))
displayCol = cols.index(st.sidebar.selectbox('Display Column', cols))
toCol = cols.index(st.sidebar.selectbox('Parent Column', cols))

code = makeGraph(rows, fromCol, toCol, displayCol)
tabGraph.graphviz_chart(code, use_container_width=True)

tabCode.code(code, language="dot", line_numbers=True)
