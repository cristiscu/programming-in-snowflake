CREATE APPLICATION ROLE hierarchical_data_role;

-- create versioned schema + view
CREATE OR ALTER VERSIONED SCHEMA code;
GRANT USAGE ON SCHEMA code
  TO APPLICATION ROLE hierarchical_data_role;

-- create secure view and functions
CREATE SECURE VIEW code.employees
AS SELECT employee, manager FROM shared.employees;
GRANT SELECT ON VIEW code.employees
  TO APPLICATION ROLE hierarchical_data_role;

CREATE SECURE FUNCTION code.get_tree_query(tableName varchar)
  RETURNS varchar
  LANGUAGE PYTHON
  RUNTIME_VERSION = 3.9
  HANDLER = 'get_tree'
AS $$
def get_tree(tableName):
  return f"""
with recursive cte (level, name, child, parent, path) as (
  select 1, $1, $1, $2, ' -> ' || $1
  from {tableName} where $2 is null
  union all
  select m.level + 1, repeat('  ', level) || e.$1, e.$1, e.$2, path || ' -> ' || e.$1
  from {tableName} e join cte m on e.$2 = m.child)
select name, path from cte order by path;
"""
$$;
GRANT USAGE ON FUNCTION code.get_tree_query(varchar)
  TO APPLICATION ROLE hierarchical_data_role;

CREATE SECURE PROCEDURE code.get_tree(tableName varchar)
  returns table(name varchar, path varchar)
  language sql
as
declare
    c1 CURSOR FOR
        with recursive cte (level, name, child, parent, path) as (
          select 1, $1, $1, $2, ' -> ' || $1
          from identifier(?) where $2 is null
          union all
          select m.level + 1, repeat('  ', level) || e.$1, e.$1, e.$2, path || ' -> ' || e.$1
          from identifier(?) e join cte m on e.$2 = m.child)
        select name, path from cte order by path;
begin
    OPEN c1 USING (:tableName, :tableName);
    RETURN TABLE(RESULTSET_FROM_CURSOR(c1));
end;
GRANT USAGE ON PROCEDURE code.get_tree(varchar)
  TO APPLICATION ROLE hierarchical_data_role;

-- add Streamlit object
CREATE STREAMLIT code.hierarchical_data_code
  FROM '/'
  MAIN_FILE = '/app.py';
GRANT USAGE ON STREAMLIT code.hierarchical_data_code
  TO APPLICATION ROLE hierarchical_data_role;
