use schema security.public;

-- =============================================
-- users
show users;
describe user MARK;
show grants to user MARK;

-- roles
show roles;
show grants to role EDITOR;
show grants of role EDITOR;

-- privileges
show grants on database SECURITY;
show future grants in schema security.public;

-- =============================================

select * from information_schema.object_privileges;

select * from snowflake.account_usage.users
  where deleted_on is null;
select * from snowflake.account_usage.roles
  where deleted_on is null;
  
select * from snowflake.account_usage.grants_to_users
  where deleted_on is null;

select * from snowflake.account_usage.grants_to_roles
  where deleted_on is null;

select name, grantee_name
  from snowflake.account_usage.grants_to_roles
  where deleted_on is null
  and privilege = 'USAGE'
  and granted_on = 'ROLE';

select grantee_name, granted_on,
  name, table_schema
  from snowflake.account_usage.grants_to_roles
  where deleted_on is null
  and table_catalog = 'SECURITY'
  and privilege = 'OWNERSHIP';
  
select privilege, grantee_name role,
  granted_on obj_type, name obj_name
  from snowflake.account_usage.grants_to_roles
  where deleted_on is null
  and table_catalog = 'SECURITY'
  and privilege <> 'OWNERSHIP'
  and granted_on <> 'ROLE';
