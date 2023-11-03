import os, configparser
import pandas as pd
import streamlit as st
import snowflake.connector

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
        cur = getConnection().cursor()
        cur.execute(query)
        rows = cur.fetch_pandas_all()
        return pd.DataFrame(rows)
    except Exception as e:
        st.error(e);
        return None

