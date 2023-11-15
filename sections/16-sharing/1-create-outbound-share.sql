-- run from producer account
use schema employees.public;

-- create share for employees.public schema objects
create share share1;
grant usage on database employees
  to share share1;
grant usage on schema employees.public
  to share share1;

-- snowflake_sample_data is already an imported database, shared with you
-- cannot share already shared data!
-- this will fail with "Granting individual privileges on imported database is not allowed..."
grant usage on database snowflake_sample_data
  to share share1;

-- create & share secure view
create or replace secure view employees as
  select e.ename as employee, m.ename as manager
  from emp e left join emp m on e.mgr = m.empno
  order by e.ename;

select * from employees;
  
grant select on view employees
  to share share1;

-- create & share secure function
create or replace secure function get_salaries_per_dept()
  returns table(dname varchar, sals float)
as 'select d.dname, sum(sal) as sals
  from emp e join dept d on e.deptno = d.deptno
  group by d.dname
  order by sals DESC';

select * from table(get_salaries_per_dept());

grant usage on function get_salaries_per_dept()
  to share share1;

-- create a reader account, if needed (replace w/ your own username and password)
create managed account reader type = reader,
  admin_name = cristiscu, admin_password = '...';

/*
{
  "accountName": "READER",
  "accountLocator": "RRR20933",
  "url": "https://kfgtkai-reader.snowflakecomputing.com",
  "accountLocatorUrl": "https://nnkd4933.snowflakecomputing.com"
}
*/

-- share w/ consumer account (replace w/ org.account, ex: YIFTMGU.RHA41860)
-- replace reader with the account name as returned before
alter share share1
  add accounts = consumer, reader

show shares;
