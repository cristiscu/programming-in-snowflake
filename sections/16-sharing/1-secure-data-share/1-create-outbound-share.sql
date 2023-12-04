-- run from producer account
use schema employees.public;

-- ==============================================================
-- create objects you want to share
create or replace secure view emp_view as
  select e.ename as employee, m.ename as manager
  from emp e left join emp m on e.mgr = m.empno
  order by e.ename;
select * from emp_view;

create or replace secure function get_salaries_per_dept()
  returns table(dname varchar, sals float)
as 'select d.dname, sum(sal) as sals
  from emp e join dept d on e.deptno = d.deptno
  group by d.dname
  order by sals DESC';
select * from table(get_salaries_per_dept());

-- ==============================================================
-- create share for employees.public schema objects
create share share1;

grant usage on database employees to share share1;
grant usage on schema employees.public to share share1;
grant select on view emp_view to share share1;
grant usage on function get_salaries_per_dept() to share share1;

-- snowflake_sample_data is already an imported database, shared with you
-- cannot share already shared data!
-- this will fail with "Granting individual privileges on imported database is not allowed..."
grant usage on database snowflake_sample_data to share share1;

-- ==============================================================
-- create a reader account, if needed (replace w/ your own username and password)
create managed account reader type = reader,
  admin_name = cscutaru, admin_password = 'Your-password';

/*
{
  "accountName": "READER",
  "accountLocator": "XJKAEIK",
  "url": "https://xjkaeik-reader.snowflakecomputing.com",
  "accountLocatorUrl": "https://klsb4933.snowflakecomputing.com"
}
*/

-- share w/ consumer account (replace w/ org.account, ex: YIFTMGU.RXB41860)
-- replace reader with the account name as returned before (ex: XJKAEIK.READER)
alter share share1 add accounts = XJKAEIK.READER, YICTMGU.RXB41860

-- show all inbound and outbound shares in this account
show shares;
