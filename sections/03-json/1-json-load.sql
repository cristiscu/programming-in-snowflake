-- select context
use schema employees.public;

-- try to infer schema from JSON data
create or replace file format myjsonformat
  TYPE = json;

SELECT *
FROM TABLE(INFER_SCHEMA(
  LOCATION => '@mystage',
  FILES => 'dept.json',
  FILE_FORMAT => 'myjsonformat'));

-- load JSON data into VARIANT
create temporary table deptt(v variant);

COPY INTO deptt
   FROM @mystage
   FILES = ('dept.json')
   FILE_FORMAT = (FORMAT_NAME = myjsonformat)
   FORCE = TRUE;

select * from deptt;

/*
{
  "data": [{
      "DEPTNO": 10,
      "DNAME": "ACCOUNTING",
      "LOC": "NEW YORK"
    },{
      "DEPTNO": 20,
      "DNAME": "RESEARCH",
      "LOC": "DALLAS"
    },{
      "DEPTNO": 30,
      "DNAME": "SALES",
      "LOC": "CHICAGO"
    },{
      "DEPTNO": 40,
      "DNAME": "OPERATIONS",
      "LOC": "BOSTON"
    }]
}
*/
