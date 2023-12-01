# show source as data frame
with tabSource:

    # from hierarchical_data_app.code schema
    defTableName = "employees"
    tableName = st.text_input("Enter full name of a table or view:", value=defTableName)
    st.button("Refresh")
    
    query = f"select * from {tableName}"
    df = connect.getDataFrame(query)
    if df is None: st.stop()
    st.dataframe(df, use_container_width=True)

# show hierarchy as returned by the Snowflake query
with tabHierarchy:

    # from hierarchical_data_app.code schema
    st.write("Generated query:")
    query = f"select get_tree_query('{tableName}')"
    query = str(connect.getRows(query)[0][0])
    st.code(query)
    
    st.write("Returned hierarchy:")
    query = f"call get_tree('{tableName}')"
    df2 = connect.getDataFrame(query)
    if df2 is None: st.stop()
    st.dataframe(df2, use_container_width=True)
