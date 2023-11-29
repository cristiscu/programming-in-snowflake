import os, configparser
import streamlit as st
from snowflake.snowpark import Session

# Get either online Snowflake session, or local session (on error)
@st.cache_resource(show_spinner="Connecting to Snowflake...")
def getSession():
    # customize with your own local connection parameters
    parser = configparser.ConfigParser()
    parser.read(os.path.join(os.path.expanduser('~'), ".snowsql/config"))
    section = "connections.demo_conn"
    pars = {
        "account": parser.get(section, "accountname"),
        "user": parser.get(section, "username"),
        "password": os.environ['SNOWSQL_PWD']
    }
    return Session.builder.configs(pars).create()

@st.cache_data(show_spinner="Running a Snowflake query...")
def runQuery(query):
    try: return getSession().sql(query).collect()
    except Exception as e: st.error(e); return None

# =================================================================

@st.cache_data(show_spinner="Getting all database names...")
def getDatabases():
    query = "show databases"
    rows = runQuery(query)
    if rows is None: st.stop()
    return [str(row["name"]) for row in rows]

@st.cache_data(show_spinner="Getting database schema names...")
def getSchemas(database):
    query = f'show schemas in database "{database}"'
    rows = runQuery(query)
    if rows is None: st.stop()
    return [str(row["name"]) for row in rows]

# select a database and schema
def getDatabaseAndSchema():
    databases = getDatabases()
    database = st.sidebar.selectbox('Database', databases, index=None)
    if database is None: return None, None

    schemas = getSchemas(database)
    sel = None if "PUBLIC" not in schemas else schemas.index("PUBLIC")
    schema = st.sidebar.selectbox('Schema', schemas, index=sel)
    return database, schema

# =================================================================

# Table Constraints
def getFKDeps(database, schema):
    query = f'show imported keys in schema "{database}"."{schema}"'
    return query, runQuery(query)

# Data Lineage
def getDataLineage(database, schema):

    if database is None:
        query = """
select distinct
  directSources.value:objectName::string as source,
  objects_modified.value:objectName::string as target
from snowflake.account_usage.access_history,
  lateral flatten(input => objects_modified) objects_modified,
  lateral flatten(input => objects_modified.value:"columns", outer => true) cols,
  lateral flatten(input => cols.value:directSources, outer => true) directSources
"""
    else:
        search = f'{database}.{schema}.' if schema is not None else f'{database}.'
        query = f"""
select distinct
  substr(directSources.value:objectName, len('{search}')+1) as source,
  substr(objects_modified.value:objectName, len('{search}')+1) as target
from snowflake.account_usage.access_history,
  lateral flatten(input => objects_modified) objects_modified,
  lateral flatten(input => objects_modified.value:"columns", outer => true) cols,
  lateral flatten(input => cols.value:directSources, outer => true) directSources
where directSources.value:objectName like '{search}%'
  or objects_modified.value:objectName like '{search}%'
"""
    return query, runQuery(query)

# Object Dependencies
def getObjDeps(database, schema):
    query = "select * from snowflake.account_usage.object_dependencies"
    if database is not None:
        query += (f"\nwhere referenced_database = '{database}'"
            + f"\n  and referencing_database = '{database}'")
        if schema is not None:
            query += (f"\n  and referenced_schema = '{schema}'"
                + f"\n  and referencing_schema = '{schema}'")
    return query, runQuery(query)

# Task Graph
def getTasks(database, schema):

    if database is None: query = f'show tasks'
    elif schema is None: query = f'show tasks in database "{database}"'
    else: query = f'show tasks in schema "{database}"."{schema}"'
    return query, runQuery(query)

@st.cache_data(show_spinner="Reading users and roles...")
def getUsersAndRoles():

    # users
    users = {}
    rows = runQuery("show users")
    for row in rows:
        users[str(row["name"])] = []

    # roles
    roles = {}
    rows = runQuery("show roles")
    for row in rows:
        roles[str(row["name"])] = []

    # user roles
    for user in users:
        rows = runQuery(f'show grants to user "{user}"')
        for row in rows:
            users[user].append(str(row["role"]))

    # role hierarchy
    for role in roles:
        rows = runQuery(f'show grants to role "{role}"')
        for row in rows:
            if (str(row["privilege"]) == "USAGE"
                and str(row["granted_on"]) == "ROLE"):
                roles[role].append(str(row["name"]))

    return users, roles
