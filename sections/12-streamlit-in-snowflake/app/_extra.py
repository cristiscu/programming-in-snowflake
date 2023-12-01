# show source as data frame
with tabSource:
    defTableName = "hierarchy_data_viewer.public.employees"
    #defTableName = "employees.public.employee_manager2"
    tableName = st.text_input("Table or view full name:", value=defTableName)
    st.button("Refresh")
    query = f"select * from {tableName}"
    df = utils.getDataFrame(query)
    if df is None: st.stop()
    st.dataframe(df, use_container_width=True)

# show hierarchy as returned by the Snowflake query
with tabHierarchy:
    query = f"""with recursive cte (level, name, child, parent, path) as (
  select 1, $1, $1, $2, ' -> ' || $1
  from {tableName} where $2 is null
  union all
  select m.level + 1, repeat('  ', level) || e.$1,
    e.$1, e.$2, path || ' -> ' || e.$1
  from {tableName} e join cte m on e.$2 = m.child)
select name, path from cte order by path;
"""
    df2 = utils.getDataFrame(query)
    if df2 is None: st.stop()
    st.dataframe(df2, use_container_width=True)

