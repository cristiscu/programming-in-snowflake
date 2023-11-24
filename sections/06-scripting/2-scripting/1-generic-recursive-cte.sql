-- select database and schema
use schema employees.public;

-- specific Recursive CTE (leave as it is)
with recursive cte (level, name, path, employee) as (
  select 1, employee, employee, employee
  from employee_manager where manager is null
  union all
  select m.level + 1,
    repeat('  ', level) || e.employee,
    path || '.' || e.employee,
    e.employee
  from employee_manager e join cte m on e.manager = m.employee)
select name, path
from cte
order by path;

-- more generic Recursive CTE (from previous)
with recursive cte (level, name, path, child) as (
  select 1, $1, $1, $1
  from employee_manager where $2 is null
  union all
  select m.level + 1,
    repeat('  ', level) || e.$1,
    path || '.' || e.$1,
    e.$1
  from employee_manager e join cte m on e.$2 = m.child)
select name, path
from cte
order by path;
