import json, urllib.parse
import streamlit as st

# "Visualize Online" button may not work in Streamlit in Snowflake
def getGraph(graph):
    try: st.link_button("Visualize Online",
        f'http://magjac.com/graphviz-visual-editor/?dot={urllib.parse.quote(graph)}')
    except: pass
    st.graphviz_chart(graph)

# get partial fully-qualified object name
def _getName(name, schema, database, skipDatabase, skipSchema):
    if not skipDatabase: return f"{database}.{schema}.{name}"
    elif not skipSchema: return f"{schema}.{name}"
    return f"{name}"

# Table Constraints
def getFkDeps(rows):

    edges, links = "", set()
    for row in rows:
        link = f'\t"{str(row["fk_table_name"])}" -> "{str(row["pk_table_name"])}";\n'
        if link not in links: links.add(link); edges += link

    graph = ('digraph {\n'
        + '\tgraph [rankdir="RL"]\n'
        + '\tnode [shape="rect"]\n'
        + '\tedge [arrowhead="none" arrowtail="crow" dir="both"]\n\n'
        + f'{edges}'
        + '}')
    return graph

# Data Lineage
def getDataLineage(rows):

    edges = ""
    for row in rows:
        nFrom = str(row[0]) if row[0] is not None else ' '
        nTo = str(row[1]) if row[1] is not None else ' '
        edges += f'\t"{nFrom}" -> "{nTo}";\n'

    graph = ('digraph {\n'
        + '\tgraph [rankdir="LR"]\n'
        + '\tnode [shape="rect"]\n\n'
        + f'{edges}'
        + '}')
    return graph

# Object Dependencies
def getObjDeps(rows, skipDatabase=False, skipSchema=False):

    ids, nodes, edges = set(), "", ""
    for row in rows:
        # referenced object
        nameTo = _getName(str(row[2]), str(row[1]), str(row[0]), skipDatabase, skipSchema)
        idTo = int(row[3]) if row[3] is not None else 0
        typeTo = str(row[4])
        if idTo not in ids:
            ids.add(idTo)
            nodes += f'\tn{idTo} [label="{nameTo}\\n({typeTo})"];\n'

        # referencing object
        nameFrom = _getName(str(row[7]), str(row[6]), str(row[5]), skipDatabase, skipSchema)
        idFrom = int(row[8]) if row[8] is not None else 0
        typeFrom = str(row[9])
        if idFrom not in ids:
            ids.add(idFrom)
            nodes += f'\tn{idFrom} [label="{nameFrom}\\n({typeFrom})"];\n'

        # add edge
        edges += f'\tn{idFrom} -> n{idTo} '

        byType = str(row[10])
        if byType == "BY_ID": edges += '[style="dotted"];\n'
        elif byType == "BY_NAME": edges += '[style="dashed"];\n'
        else: edges += '[style="solid"];\n'

    graph = ('digraph {\n'
        + '\tgraph [rankdir="LR"]\n'
        + '\tnode [shape="rect"]\n\n'
        + f'{nodes}\n'
        + f'{edges}'
        + '}')
    return graph

def getAllTasks(rows, skipDatabase=False, skipSchema=False):

    edges = ""
    for row in rows:
        name = _getName(str(row[1]), str(row[4]), str(row[3]), skipDatabase, skipSchema)
        predecessors = json.loads(str(row[9]))
        for parent in predecessors:
            parts = parent.split('.')
            parent = _getName(parts[2], parts[1], parts[0], skipDatabase, skipSchema)
            edges += f'\t"{parent}" -> "{name}";\n'

    graph = ('digraph {\n'
        + '\tgraph [rankdir="TB"]\n'
        + '\tnode [shape="rect"]\n\n'
        + f'{edges}'
        + '}')
    return graph

def getUsersAndRoles(users, roles, showSystem, showUsers):

    sysroles = [ "ACCOUNTADMIN", "SYSADMIN", "USERADMIN",
        "SECURITYADMIN", "ORGADMIN", "PUBLIC", "ORGADMIN" ];

    nodes = ""
    for name in roles:
        if name not in sysroles or showSystem:
            fillcolor = "#e6c6d6" if name in sysroles else "#ededed"
            nodes += f'\t"{name}" [style="filled" fillcolor="{fillcolor}"];\n'
    if showUsers:
        for name in users:
            nodes += f'\t"{name}" [shape="ellipse" style="dashed"];\n'

    edges = ""
    for name in roles.keys():
        if name not in sysroles or showSystem:
            for role in roles[name]:
                if role not in sysroles or showSystem:
                    edges += f'\t"{name}" -> "{role}";\n'
    if showUsers:
        for name in users.keys():
            for role in users[name]:
                if role not in sysroles or showSystem:
                    edges += f'\t"{name}" -> "{role}" [style="dashed"];\n'

    graph = ('digraph {\n'
        + '\tgraph [rankdir="LR"]\n'
        + '\tnode [shape="rect"]\n\n'
        + f'{nodes}\n'
        + f'{edges}'
        + '}')
    return graph

