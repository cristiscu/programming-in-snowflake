show users;
show roles;

-- user roles
show grants to user ...;

-- role hierarchy
-- (if privilege = 'USAGE' and granted_on = 'ROLE')
show grants to role ...;

-- ex: for a specific role
show grants to role EDITOR;

select "name"
from table(result_scan(last_query_id()))
where "privilege" = 'USAGE' and "granted_on" = 'ROLE';