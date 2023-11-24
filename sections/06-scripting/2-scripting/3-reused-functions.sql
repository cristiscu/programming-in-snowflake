-- select database and schema
use schema employees.public;

-- generic tree query (as JS UDF)
create or replace function get_tree_query(tableName varchar)
  returns string
  language javascript
as $$
return `with recursive cte (level, name, path, child) as (
  select 1, $1, $1, $1
  from ${TABLENAME} where $2 is null
  union all
  select m.level + 1, repeat('  ', level) || e.$1,
    path || '.' || e.$1, e.$1
  from ${TABLENAME} e join cte m on e.$2 = m.child)
select name, path from cte order by path`
$$;

select get_tree_query('employee_manager');

/*
with recursive cte (level, name, path, child) as (
  select 1, $1, $1, $1
  from employee_manager where $2 is null
  union all
  select m.level + 1, repeat('  ', level) || e.$1,
    path || '.' || e.$1, e.$1
  from employee_manager e join cte m on e.$2 = m.child)
select name, path from cte order by path
*/  

-- generic tree display (w/ EXECUTE IMMEDIATE and RESULTSET)
-- (as Snowflake Scripting SP calling the JS UDF)
create or replace procedure show_tree_simple(tableName varchar)
  returns table(name varchar, path varchar)
  language sql
as
declare
  stmt string;
begin
  select get_tree_query(:tableName) into stmt;
  let rs resultset := (execute immediate :stmt);
  return table(rs);
end;

call show_tree_simple('employee_manager');
