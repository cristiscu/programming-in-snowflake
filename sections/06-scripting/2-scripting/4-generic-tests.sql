-- select database and schema
use schema employees.public;

-- call after data/animals.csv uploaded in @mystage
create or replace table animals (child varchar, parent varchar);
copy into animals from @mystage
  files = ('animals.csv')
  file_format = (format_name = mycsvformat)
  match_by_column_name = case_insensitive;
select * from animals;
call show_tree_simple('animals');

-- call after data/file-system.csv uploaded in @mystage
create or replace table file_system (subfolder varchar, folder varchar);
copy into file_system from @mystage
  files = ('file-system.csv')
  file_format = (format_name = mycsvformat)
  match_by_column_name = case_insensitive;
select * from file_system;
call show_tree_simple('file_system');

-- call after data/flare.csv uploaded in @mystage
create or replace table flare (child varchar, parent varchar);
copy into flare from @mystage
  files = ('flare.csv')
  file_format = (format_name = mycsvformat)
  match_by_column_name = case_insensitive;
select * from flare;
call show_tree_simple('flare');

-- call after data/portfolio.csv uploaded in @mystage
create or replace table portfolio (child varchar, parent varchar);
copy into portfolio from @mystage
  files = ('portfolio.csv')
  file_format = (format_name = mycsvformat)
  match_by_column_name = case_insensitive;
select * from portfolio;
call show_tree_simple('portfolio');
