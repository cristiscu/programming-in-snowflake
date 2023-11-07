import os, configparser
import pandas as pd
import streamlit as st
from snowflake.snowpark import Session
from snowflake.snowpark.context import get_active_session

# customize with your own Snowflake connection parameters
@st.cache_resource(show_spinner="Connecting to Snowflake...")
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
            "password": os.environ['SNOWSQL_PWD'],
            "database": "hierarchy_data_app",
            "schema": "code_schema"
        }
        return Session.builder.configs(pars).create()

@st.cache_data(show_spinner="Running a Snowflake query...")
def getRows(query):
    try:
        return getSession().sql(query).collect()
    except Exception as e:
        st.error(e);
        return None

def getDataFrame(query):
    rows = getRows(query)
    return pd.DataFrame(rows).convert_dtypes() if rows is not None else None
