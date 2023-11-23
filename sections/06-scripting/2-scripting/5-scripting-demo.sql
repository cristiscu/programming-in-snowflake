-- select test database and schema
use schema employees.public;

create or replace view employees as 
  select e.ename as employee, m.ename as manager 
  from emp e left join emp m on e.empno = m.empno
  order by e.ename;

create or replace function get_tree_query()
  returns varchar
  language sql
as $$
  SELECT 'with cte as (
      select e.employee as name,
        coalesce(coalesce(coalesce(
          ' -> ' || m3.employee, '')
          || ' -> ' || m2.employee, '')
          || ' -> ' || m1.employee, '')
          || ' -> ' || e.employee as path,
        e.job as title
      from employees e
        left join employees m1 on e.manager = m1.employee
        left join employees m2 on m1.manager = m2.employee
        left join employees m3 on m2.manager = m3.employee
  )
  select repeat('  ', array_size(split(path, '->'))-1)
    || name as name, path, title
  from cte
  order by path'
$$;

SELECT get_tree_query();

create procedure get_tree()
  returns table(name varchar, path varchar)
  language sql
as
declare
    c1 CURSOR FOR
        with cte as (
            select e.employee as name,
              coalesce(coalesce(coalesce(
                ' -> ' || m3.employee, '')
                || ' -> ' || m2.employee, '')
                || ' -> ' || m1.employee, '')
                || ' -> ' || e.employee as path,
              e.job as title
            from employees e
              left join employees m1 on e.manager = m1.employee
              left join employees m2 on m1.manager = m2.employee
              left join employees m3 on m2.manager = m3.employee
        )
        select repeat('  ', array_size(split(path, '->'))-1)
          || name as name, path, title
        from cte
        order by path;
begin
    OPEN c1
    RETURN TABLE(RESULTSET_FROM_CURSOR(c1));
end;

CALL get_tree();
