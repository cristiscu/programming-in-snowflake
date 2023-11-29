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


def getUsersAndRoles():

    # users and roles
    session, users, roles = getSession(), {}, {}
    
    rows = session.sql("show users").collect()
    for row in rows: users[str(row["name"])] = []
    
    rows = session.sql("show roles").collect()
    for row in rows: roles[str(row["name"])] = []

    # user roles
    for user in users:
        query = f'show grants to user "{user}"'
        rows = session.sql(query).collect()
        for row in rows:
            users[user].append(str(row["role"]))

    # role hierarchy
    for role in roles:
        query = f'show grants to role "{role}"'
        rows = session.sql(query).collect()
        for row in rows:
            if (str(row["privilege"]) == "USAGE"
                and str(row["granted_on"]) == "ROLE"):
                roles[role].append(str(row["name"]))

    return users, roles


def getGraph(users, roles):

    sysroles = [ "ACCOUNTADMIN", "SYSADMIN", "USERADMIN",
        "SECURITYADMIN", "ORGADMIN", "PUBLIC", "ORGADMIN" ];

    nodes = ""
    for name in roles:
        fillcolor = "#e6c6d6" if name in sysroles else "#ededed"
        nodes += f'\t"{name}" [style="filled" fillcolor="{fillcolor}"];\n'
    for name in users:
        nodes += f'\t"{name}" [shape="ellipse" style="dashed"];\n'

    edges = ""
    for name in roles.keys():
        for role in roles[name]:
            edges += f'\t"{name}" -> "{role}";\n'
    for name in users.keys():
        for role in users[name]:
            edges += f'\t"{name}" -> "{role}";\n'

    graph = ('digraph { graph [rankdir=TB] node [shape=rect] edge [dir=back]\n'
        + f'{nodes}\n{edges}}}')
    return graph


st.set_page_config(layout="wide")
st.title("Users and Roles")

users, roles = getUsersAndRoles()
st.graphviz_chart(getGraph(users, roles))