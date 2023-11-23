-- select context
use schema employees.public;

-- SQL (Scripting) user-defined function (UDF)
create or replace function get_manager(name string)
  returns string
as $$
  select manager
  from employee_manager
  where employee = name
$$;
-- as 'select manager from employee_manager where employee = name';

select get_manager('BLAKE');
select get_manager('nobody');

-- SQL (Scripting) user-defined table function (UDTF)
create or replace function get_subordinates(name string)
  returns table(employee string)
as 'select employee from employee_manager where manager = name';

select * from table(get_subordinates('BLAKE'));
select * from table(get_subordinates('nobody'));

-- JavaScript stored procedure
create or replace procedure find_manager(name string)
  returns string
  language javascript
as $$
  var query = "select manager from employee_manager where employee = ?";
  var stmt = snowflake.createStatement({sqlText: query, binds: [NAME]});
  var res = stmt.execute();
  return res.next() ? res.getColumnValue(1) : null;
$$;

call find_manager('BLAKE');
call find_manager('nobody');
-- select * from table(result_scan(last_query_id()));
