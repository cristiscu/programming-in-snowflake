-- create roles
create or replace role alice;
grant role alice to role sysadmin;
create or replace role bob;
grant role bob to role sysadmin;

-- create database
create or replace database alice_db;
grant ownership on database alice_db to role alice;
grant ownership on schema alice_db.public to role alice;
grant usage on warehouse compute_wh to role alice;

create or replace database bob_db;
grant ownership on database bob_db to role bob;
grant ownership on schema bob_db.public to role bob;
grant usage on warehouse compute_wh to role bob;

-- Alice hides her wealth in her table
use role alice;
create table alice_db.public.my_wealth as select 1110000 as wealth;

-- Bob hides his wealth in his table
use role bob;
create table bob_db.public.my_wealth as select 1250000 as wealth;

-- Bob grants usage on his protected table to Alice
create row access policy bob_db.public.mask_wealth
  as (wealth int) returns boolean ->
  current_role() in ('ACCOUNTADMIN', 'BOB')
    or current_statement() = 'select case
when bob.wealth > alice.wealth then \'Bob is richer\'
when bob.wealth = alice.wealth then \'Neither is richer\'
else \'Alice is richer\' end as result
from bob_db.public.my_wealth bob,
alice_db.public.my_wealth alice
where exists (
select table_name
from alice_db.information_schema.tables
where table_schema = \'PUBLIC\'
and table_name = \'MY_WEALTH\'
and table_type = \'BASE TABLE\');';
alter table bob_db.public.my_wealth
  add row access policy bob_db.public.mask_wealth on (wealth);

grant usage on database bob_db to role alice;
grant usage on schema bob_db.public to role alice;
grant select on table bob_db.public.my_wealth to role alice;

-- Alice tries to find Bob's wealth, but only last query will succeed
use role alice;
select * from bob_db.public.my_wealth;

select case
when bob.wealth > alice.wealth then 'Bob is richer'
when bob.wealth = alice.wealth then 'Neither is richer'
else 'Alice is richer' end as result
from bob_db.public.my_wealth bob,
alice_db.public.my_wealth alice
where exists (
select table_name
from alice_db.information_schema.tables
where table_schema = 'PUBLIC'
and table_name = 'MY_WEALTH'
and table_type = 'BASE TABLE');
