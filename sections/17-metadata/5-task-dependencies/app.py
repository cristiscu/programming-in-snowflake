import json, os, configparser
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


def getGraph(rows, database, schema):
    s = ""
    for row in rows:
        name = str(row["name"])
        predecessors = json.loads(str(row["predecessors"]))
        for parent in predecessors:
            parts = parent.split('.')
            if database == parts[0] and schema == parts[1]: parent = parts[2]
            s += f'\t"{parent}" -> "{name}";\n'
    graph = f'digraph {{ graph [rankdir=LR] node [shape=rect]\n{s}}}'
    return graph


database, schema = "TASKS_DB", "PUBLIC"
st.set_page_config(layout="wide")
st.title(f"Task Dependencies in {database}.{schema}")

query = f'show tasks in schema "{database}"."{schema}"'
rows = getSession().sql(query).collect()
st.graphviz_chart(getGraph(rows, database, schema))
