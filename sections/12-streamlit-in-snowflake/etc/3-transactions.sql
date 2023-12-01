create or replace table audit_users (start_ts timestamp, user varchar);
create or replace table audit_queries (start_ts timestamp, query varchar);

create or replace procedure audit_user(user varchar)
  returns string
as 
begin
  begin transaction;
    insert into audit_users values(current_timestamp, user);
  commit;
exception
  when other then
    rollback;
end;

create or replace procedure audit_query (query varchar)
  returns string
as
begin
  begin transaction;
    insert into audit_query values(current_timestamp, query);
  commit;
exception
  when other then
    rollback;
end;