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
    s = ""
    for row in rows:
        refing = f"{str(row[0])}\n({str(row[1])})"
        refed = f"{str(row[2])}\n({str(row[3])})"
        s += f'\t"{refing}" -> "{refed}";\n'
    graph = f'digraph {{graph [rankdir=LR] node [shape=rect] {s}}}'
    return graph;


database, schema = "EMPLOYEES", "PUBLIC"
st.set_page_config(layout="wide")
st.title(f"Object Dependencies in {database}.{schema}")

query = f"call obj_deps.public.show_deps('{database}', '{schema}')"
rows = getSession().sql(query).collect()
st.graphviz_chart(getGraph(rows))
