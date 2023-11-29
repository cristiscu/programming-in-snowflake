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
        pk, fk = str(row["pk_table_name"]), str(row["fk_table_name"])
        style = ' [style="dashed"]' if pk == fk else ''
        link = f'\t"{fk}" -> "{pk}"{style};\n'
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
        nFrom = str(row[0]) if row[0] is not None and len(str(row[0])) > 0 else ' '
        nTo = str(row[1]) if row[1] is not None and len(str(row[1])) > 0 else ' '
        if nFrom != ' ' or nTo != ' ': edges += f'\t"{nFrom}" -> "{nTo}";\n'

    graph = ('digraph {\n'
        + '\tgraph [rankdir="LR"]\n'
        + '\tnode [shape="rect"]\n\n'
        + f'\t " " [shape="ellipse"];\n\n'
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
        + '\tgraph [rankdir="LR"]\n'
        + '\tnode [shape="rect"]\n\n'
        + f'{edges}'
        + '}')
    return graph

def getUsersAndRoles(users, roles,
    showUsers, showRoles, showSystemRoles, showGroups):

    sysroles = [ "ACCOUNTADMIN", "SYSADMIN", "USERADMIN",
        "SECURITYADMIN", "ORGADMIN", "PUBLIC", "ORGADMIN" ];

    nodes = ""
    if showRoles or showSystemRoles:
        if showGroups:
            nodes += '\t// roles\n'
            nodes += f'\tsubgraph cluster_0 {{\n\tstyle="dotted";\n\tlabel="roles";\n\n'
        for name in roles:
            if ((showSystemRoles and name in sysroles)
                or (showRoles and name not in sysroles)):
                fillcolor = "#e6c6d6" if name in sysroles else "#ededed"
                nodes += f'\t"{name}" [style="filled" fillcolor="{fillcolor}"];\n'
        if showGroups:
            nodes += '\t}\n\n'

    if showUsers:
        if showGroups:
            nodes += '\t// users\n'
            nodes += f'\tsubgraph cluster_1 {{\n\tstyle="dotted";\n\tlabel="users";\n\n'
        for name in users:
            nodes += f'\t"{name}" [shape="ellipse" style="dashed"];\n'
        if showGroups:
            nodes += '\t}\n\n'

    edges = '\t// role hierarchy\n'
    if showSystemRoles:
        edges += '\t"SYSADMIN" -> "PUBLIC" [style="dotted"];\n'
        edges += '\t"USERADMIN" -> "PUBLIC" [style="dotted"];\n'
        edges += '\t"ACCOUNTADMIN" -> "ORGADMIN" [style="dotted"];\n'
    if showRoles or showSystemRoles:
        for name in roles.keys():
            if ((showSystemRoles and name in sysroles)
                or (showRoles and name not in sysroles)):
                if (showSystemRoles and name not in sysroles
                    and "PUBLIC" not in roles[name]):
                    edges += f'\t"{name}" -> "PUBLIC" [style="dotted"];\n'
                for role in roles[name]:
                    if ((showSystemRoles and role in sysroles)
                        or (showRoles and role not in sysroles)):
                        edges += f'\t"{name}" -> "{role}";\n'

    if showUsers and (showRoles or showSystemRoles):
        edges += '\n\t// user roles\n'
        for name in users.keys():
            for role in users[name]:
                if ((showSystemRoles and role in sysroles)
                    or (showRoles and role not in sysroles)):
                    edges += f'\t"{name}" -> "{role}" [style="dashed"];\n'

    graph = ('digraph {\n'
        + '\tgraph [rankdir="TB"]\n' # splines="ortho"
        + '\tnode [shape="rect"]\n'
        + '\tedge [dir="back"]\n\n'
        + f'{nodes}\n'
        + f'{edges}'
        + '}')
    return graph

