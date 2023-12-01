import urllib.parse
import pandas as pd
import streamlit as st
import modules.utils as utils
from modules.query_profiler import QueryProfiler
from modules.query_analyzer import QueryAnalyzer

st.set_page_config(layout="wide")
st.title("Enhanced Query Profile")
st.caption("Display additional information for a Snowflake query.")

# get a query ID (could execute in Snowsight and get ID)
queryId = ""
defQueryId, queryText = QueryAnalyzer.getLastQuery()
if defQueryId is not None:
    queryId = st.sidebar.text_input('Query Id', value=defQueryId)
if len(queryId) == 0:
    st.warning("Enter a query ID!")
    st.stop()

# find query text in INFORMATION_SCHEMA or ACCOUNT_USAGE
analyzer = QueryAnalyzer(queryId)
if queryId != defQueryId:
    queryText = analyzer.getQueryText()
    if queryText is None: st.error("Query not found!"); st.stop()

query = analyzer.getQueryProfileQuery()
rows = utils.runQuery(query)
if rows is None: st.stop()
df = pd.DataFrame(rows).convert_dtypes()
if df.size == 0: st.warning("No data!"); st.stop()

tabQuery, tabAnalysis, tabGraph, tabMetadata, tabExplain \
    = st.tabs(["Query", "Analysis", "Graph", "Metadata", "Explain"])

with tabQuery:
    st.code(queryText)
    rowsQ = utils.runQuery(queryText)
    if rowsQ is not None:
        dfQ = pd.DataFrame(rowsQ).convert_dtypes()
        st.dataframe(dfQ.head(1000), use_container_width=True)
        st.write("Max 1,000 rows are displayed here.")

with tabAnalysis:
    st.code(analyzer.getAnalysis())

with tabGraph:
    profiler = QueryProfiler()
    graph = profiler.getQueryProfile(rows)

    # "Visualize Online" button may not work in Streamlit in Snowflake
    try: st.link_button("Visualize Online",
        f'http://magjac.com/graphviz-visual-editor/?dot={urllib.parse.quote(graph)}')
    except: pass

    st.graphviz_chart(graph)

with tabMetadata:
    st.code(query)
    st.dataframe(df.head(1000), use_container_width=True)
    st.write("Max 1,000 rows are displayed here.")

with tabExplain:
    st.code(f"explain using text\n\t{queryText}")
    st.code(QueryAnalyzer.getExplain(queryText))
