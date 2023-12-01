import os, configparser
import pandas as pd
import streamlit as st
import snowflake.connector

def getFullPath(filename):
    #return f"{os.path.dirname(__file__)}/{filename}"
    crtdir = os.path.dirname(__file__)
    pardir = os.path.abspath(os.path.join(crtdir, os.pardir))
    return f"{pardir}/{filename}"

# customize with your own Snowflake connection parameters
@st.cache_resource(show_spinner="Connecting to Snowflake...")
def getConnection():
    parser = configparser.ConfigParser()
    parser.read(os.path.join(os.path.expanduser('~'), ".snowsql/config"))
    section = "connections.demo_conn"

    return snowflake.connector.connect(
        account=parser.get(section, "accountname"),
        user=parser.get(section, "username"),
        password=os.environ['SNOWSQL_PWD'],
        database='EMPLOYEES',
        schema='PUBLIC')

@st.cache_data(show_spinner="Running a Snowflake query...")
def getDataFrame(query):
    try:
        conn = getConnection()
        if not query.lower().startswith("select "):
            return pd.read_sql(query, conn)
        else:
            cur = conn.cursor()
            cur.execute(query)
            return cur.fetch_pandas_all()
    except Exception as e:
        st.error(e)
        return None
