-- select context

create database if not exists tests;
use schema tests.public;

/*
[
  {
    "name": 'John',
    "managers": [
      { "name": "Bill", "years": [2021, 2022] },
      { "name": "Linda", "years": [2020] }
    ]
  },{
    "name": 'Mary',
    "managers": [
      { "name": "Bill", "years": [2022, 2023] }
    ]
  }
]
*/

-- insert inline JSON --> VARIANT
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

select * from json;

-- one-level flattening with TABLE-FLATTEN
select j.name, m.value, m.value:name::string, m.value:years
  from json j, table(flatten(input => j.v, path => 'managers')) m;

-- one-level flattening with LATERAL-FLATTEN join
select name, m.value, m.value:name::string, m.value:years
  from json j, lateral flatten(input => j.v, path => 'managers') m;

-- two-level flattening with multiple LATERAL (outer!) joins
select name, 
    m.value, m.value:name::string, m.value:years,
    y.value
  from json j,
    lateral flatten(input => j.v, path => 'managers', outer => true) m,
    lateral flatten(input => m.value, path => 'years', outer => true) y;
