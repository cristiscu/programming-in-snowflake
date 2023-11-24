-- select database and schema
use schema employees.public;

-- generic tree display (as Snowflake Scripting SP, w/ CURSOR)
create or replace procedure show_tree(tableName varchar)
  returns table(name varchar, path varchar)
  language sql
as
declare
  c1 cursor for
    with recursive cte (level, name, path, child) as (
      select 1, $1, $1, $1
      from identifier(?) where $2 is null
      union all
      select m.level + 1, repeat('  ', level) || e.$1,
        path || '.' || e.$1, e.$1
      from identifier(?) e join cte m on e.$2 = m.child)
    select name, path from cte order by path;
begin
  open c1 using (:tableName, :tableName);
  return table(resultset_from_cursor(c1));
end;

call show_tree('employee_manager');

-- generic tree display (as Snowflake Scripting SP, w/ RESULTSET)
create or replace procedure show_tree_rs(tableName varchar)
  returns table(name varchar, path varchar)
  language sql
as
declare
  rs resultset default (
    with recursive cte (level, name, path, child) as (
      select 1, $1, $1, $1
      from identifier(:tableName) where $2 is null
      union all
      select m.level + 1, repeat('  ', level) || e.$1,
        path || '.' || e.$1, e.$1
      from identifier(:tableName) e join cte m on e.$2 = m.child)
    select name, path from cte order by path);
begin
  return table(rs);
end;

call show_tree_rs('employee_manager');
