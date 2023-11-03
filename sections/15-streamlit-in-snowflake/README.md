Streamlit in Snowflake
======================

* Add scripts/deploy.sql, to call with **snowsql -c demo_conn -f scripts/deploy.sql**
* Use variable substitution for **&CRT_DIR** in PUT commands.
* Separate in **m6_connect.py** *getSession()* and *getDataFrame()*.
* Replace *snowflake.connector* with **snowflake.snowpark** (plus adjust reading into DataFrame).
* Create a local table **hierarchy_data_viewer.public.employees** from uploaded *data/employee-manager.csv*.
* Set *defTableName* to new local table (instead of "employees.public.employee_manager2").
* Keep only *getEdges()* for DOT graphviz module.
* No *graphviz* module (but DOT supported).
* Streamlit's *st.link_button* not supported (removed from tabGraph).
* Add *plotly* to **environment.yml** (*requirements.txt* not considered).
* No D3 diagrams (Streamlit's *component* not supported) --> remove all Animated (module, templates, tabAnim).
* No network diagram anyway (no *pyvis*, *networkx* packages).
