-- select test database and schema
use schema employees.public;

-- case insensitive
create table Abc(v variant);
seLECT V from aBC;
drop table ABC;

-- case sensitive
create table "Abc"("v" variant);
select V from aBC;
select "v" from "Abc";
drop table ABC;
drop table "Abc";
