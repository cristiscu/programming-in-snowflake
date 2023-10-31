-- select test database and schema
use schema employees.public;

-- show details on emp table
describe table emp;
show tables in database;

-- add comment on emp table
comment on table emp is 'This is the employee table';
show tables;

-- duplicate dept table (dept_like with no data)
create table dept_ctas as select * from dept;
create table dept_like like dept;
create table dept_clone clone dept;

-- returns 4 rows, for dedups (union all returns 8)
select * from dept_ctas
union
select * from dept_like
union
select * from dept_clone;

-- multi-table insert (no PK enforced!)
insert first
  when deptno <= 20
  then into dept_ctas
  else into dept_clone
select * from dept;

select * from dept_ctas;
select * from dept_clone;

-- update all rows from dept_ctas (always use WHERE!)
update dept_ctas
  set dname = 'deleted'
  from dept
  where dept_ctas.deptno = dept.deptno;
select * from dept_ctas;

-- copy all from one table into the empty table (truncate it anyway)
insert overwrite into dept_like select * from dept_clone;
select * from dept_like;

-- delete all rows
delete from dept_clone;
select * from dept_clone;

truncate table dept_like;
select * from dept_like;

-- drop all 3 new tables
drop table dept_ctas;
drop table dept_like;
drop table dept_clone;

show tables in database;
