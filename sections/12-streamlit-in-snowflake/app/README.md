# Streamlit in Snowflake App

Streamlit in Snowflake should use Snowpark to connect to Snowflake, not just the client Python Connector for Snowflake (included in Snowpark anyway). When a *get_active_sesion()* call fails, we assume we are testing locally, and connect to Snowflake as we did before, from an external client application.

* Replace *snowflake.connector* with **snowflake.snowpark** (plus adjust reading into DataFrame).
* Separate in **m6_connect.py** *getSession()* and *getDataFrame()*.

A new SQL script can be manually or automatically executed by the SnowSQL CLI, to deploy the required application files into a stage in Snowflake, through PUT commands. Then a STREAMLIT object is created for these files.

* Add scripts/deploy.sql, to call with **snowsql -c demo_conn -f scripts/deploy.sql**
* Use variable substitution for **&CRT_DIR** in PUT commands.
* Create a local table **hierarchy_data_viewer.public.employees** from uploaded *data/employee-manager.csv*.
* Set *defTableName* to new local table (instead of "employees.public.employee_manager2").

There are known and unknown limitations for Streamlit in Snowflake. Not everything that worked as a Streamlit web app will also work in the new environment.

* Add *plotly* to **environment.yml** (*requirements.txt* not considered).
* Keep only *getEdges()* for DOT graphviz module.
* No *graphviz* module (but DOT supported).
* Streamlit's *st.link_button* not supported (removed from tabGraph).
* No D3 diagrams (Streamlit's *component* not supported) --> remove all Animated (module, templates, tabAnim).
* No network diagram anyway (no *pyvis*, *networkx* packages).
