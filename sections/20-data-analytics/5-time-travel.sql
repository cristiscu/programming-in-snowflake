create or replace database time_travel;
create or replace table persons (id int, name string, ts timestamp);

-- =============================================================
-- time travel settings
show parameters like 'data_retention_time_in_days' in account;
show parameters like 'data_retention_time_in_days' in database;
show parameters like 'data_retention_time_in_days' in schema;
show parameters like 'data_retention_time_in_days' for table persons;

alter table persons set data_retention_time_in_days = 3;

-- =============================================================
-- time travel SELECT (looking back in time)
insert into persons values (1, 'Mike', current_timestamp());

set ts = (select current_timestamp());
insert into persons values (2, 'Mary', $ts);
select * from persons at (timestamp => $ts);
select * from persons before (timestamp => current_timestamp());

insert into persons values (3, 'George', current_timestamp());
set qid = (select last_query_id());

-- Mike, Mary, George
select * from persons;
-- Mike, Mary
select * from persons before (statement => $qid);
-- Mike
select * from persons before (timestamp => $ts);
-- negative, relative, in seconds
select * from persons at (offset => -60);

-- =============================================================
-- data recovery with time travel
drop table persons;
undrop table persons;

truncate persons;
create table persons2 clone persons before (statement => last_query_id());
select * from persons2;

drop table persons;
alter table persons2 rename to persons;

show tables history;
