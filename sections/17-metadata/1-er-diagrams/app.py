import os, configparser
import streamlit as st
from snowflake.snowpark import Session

def getSession():
    parser = configparser.ConfigParser()
    parser.read(os.path.join(os.path.expanduser('~'), ".snowsql/config"))
    section = "connections.demo_conn"

    pars = {
        "account": parser.get(section, "accountname"),
        "user": parser.get(section, "username"),
        "password": os.environ['SNOWSQL_PWD'] }
    return Session.builder.configs(pars).create()


def getGraph(rows):
    s, links = "", set()
    for row in rows:
        pk, fk = str(row["pk_table_name"]), str(row["fk_table_name"])
        link = f'\t"{fk}" -> "{pk}";\n'
        if link not in links:
            links.add(link)
            s += link
    graph = ('digraph {graph [rankdir=RL] node [shape=rect] '
        + 'edge [arrowhead=none arrowtail=crow dir=both] '
        + f'{s}}}')
    return graph;


database, schema = "Chinook", "PUBLIC"
st.set_page_config(layout="wide")
st.title(f"Entity-Relationship Diagram of {database}.{schema}")

query = f'show imported keys in schema "{database}"."{schema}"'
rows = getSession().sql(query).collect()
st.graphviz_chart(getGraph(rows))
