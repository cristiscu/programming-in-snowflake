-- run from consumer or reader account (switch to ACCOUNTADMIN!)
-- if reader account, create a warehouse first!

-- after Data > Private Sharing > SHARE1 in Direct Shares --> Get as DB_SHARE1 database
-- replace producer w/ the account number (as in RHA41860)
-- create or replace database db_share1
--   from share producer.share1;
use db_share1.public;

-- grant imported privileges
--   on database db_share1 to role role2;

-- test the secure view (only employees from RESEARCH returned!)
select * from employees;

-- test the secure function (only RESEARCH returned!)
select * from table(get_salaries_per_dept());
