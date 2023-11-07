-- select context
use schema employees.public;

- insert inline JSON --> VARIANT
create or replace table json(name string, v variant) as
  select 'John', parse_json($${
    "managers": [
      { "name": "Bill", "years": [2021, 2022] },
      { "name": "Linda", "years": [2020] }
    ]}$$)
  union
  select 'Mary', parse_json($${
    "managers": [
      { "name": "Bill", "years": [2022, 2023] }
    ]}$$);

select *
  from json;

-- one-level flattening with TABLE-FLATTEN
select j.name,
    m.value, m.value:name::string, m.value:years
  from json j,
    table(flatten(input => j.v, path => 'managers')) m;

-- one-level flattening with LATERAL-FLATTEN join
select name,
    m.value, m.value:name::string, m.value:years
  from json j,
    lateral flatten(input => j.v, path => 'managers') m;

-- two-level flattening with multiple LATERAL joins
select name, 
    m.value, m.value:name::string, m.value:years,
    y.value
  from json j,
    lateral flatten(input => j.v, path => 'managers') m,
    lateral flatten(input => m.value, path => 'years') y;
