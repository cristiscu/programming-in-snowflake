-- select test database and schema
use schema employees.public;

select * from dept;

create table dept_1 as select * from dept;
select * from dept_1;

create table deptc clone dept;
select * from deptc;

insert into dept values (50, 'MAILROOM', 'ATLANTA');
select * from dept;
select * from deptc;

insert into deptc values (60, 'DEVELOPMENT', 'CHICAGO');
select * from deptc;
select * from dept;

update dept set loc='MIAMI' where deptno=10;
select * from dept;
select * from deptc;

update deptc set loc='SEATTLE' where deptno=10;
select * from deptc;
select * from dept;

delete from dept where loc='MIAMI' where deptno=10;
select * from dept;
select * from deptc;
