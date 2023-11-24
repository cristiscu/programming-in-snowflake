-- select test database and schema
use schema employees.public;

create table abc(v variant);
select v from abc;
select v from employees.public.abc;
select v from identifier('abc');
set table_name = 'abc';
select v from identifier($table_name);
select $1 from abc;
drop table abc;
