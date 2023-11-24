-- select test database and schema
use schema employees.public;
select * from dept;

-- CREATE TABLE ... LIKE ... 
create table dept_like like dept;
select * from dept_like;
insert overwrite into dept_like select * from dept;
select * from dept_like;

truncate table dept_like;
select * from dept_like;
drop table dept_like;

-- CREATE TABLE ... SELECT ... (CTAS)
create table dept_ctas as select * from dept;
select * from dept_ctas;

-- CREATE TABLE ... CLONE ... (zero-copy cloning)
create table dept_cloned clone dept_ctas;
select * from dept_cloned;

insert into dept_ctas values (50, 'MAILROOM', 'ATLANTA');
select * from dept_ctas;
select * from dept_cloned;

insert into dept_clones values (60, 'DEVELOPMENT', 'CHICAGO');
select * from dept_cloned;
select * from dept_ctas;

update dept_ctas set loc='MIAMI' where deptno=10;
select * from dept_ctas;
select * from dept_cloned;

update dept_cloned set loc='SEATTLE' where deptno=10;
select * from dept_cloned;
select * from dept_ctas;

delete from dept_ctas where loc='MIAMI' where deptno=10;
select * from dept_ctas;
select * from dept_cloned;

-- multi-table insert (no PK enforced!)
select * from dept;
insert first
  when deptno <= 20
  then into dept_ctas
  else into dept_cloned
select * from dept;

select * from dept_ctas;
select * from dept_clone;

-- update all rows from dept_ctas (always use WHERE!)
update dept_ctas
  set dname = 'deleted'
  from dept
  where dept_ctas.deptno = dept.deptno;
select * from dept_ctas;

select * from dept_ctas;
select * from dept_clone;

-- cleanup
drop table dept_ctas;
drop table dept_cloned;
show tables in database;