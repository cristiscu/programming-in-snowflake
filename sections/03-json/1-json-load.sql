-- Customer Request 2 --> JSON processing

-- select context
use schema employees.public;

create or replace file format myjsonformat
  TYPE = json;

SELECT * FROM TABLE(
    INFER_SCHEMA(
        LOCATION=>'@mystage',
        FILES => 'dept.json',
        FILE_FORMAT=>'myjsonformat'));

create or replace table dept2(v variant);

COPY INTO dept2
   FROM @mystage
   FILES = ('dept.json')
   FILE_FORMAT = (FORMAT_NAME = myjsonformat)
   FORCE = TRUE;

select * from dept2;

{
  "data": [
    {
      "DEPTNO": 10,
      "DNAME": "ACCOUNTING",
      "LOC": "NEW YORK"
    },
    {
      "DEPTNO": 20,
      "DNAME": "RESEARCH",
      "LOC": "DALLAS"
    },
    {
      "DEPTNO": 30,
      "DNAME": "SALES",
      "LOC": "CHICAGO"
    },
    {
      "DEPTNO": 40,
      "DNAME": "OPERATIONS",
      "LOC": "BOSTON"
    }
  ]
}

create or replace table dept22 as
select dept.value:DEPTNO::number(2,0) as deptno,
    dept.value:DNAME::varchar(20) as dname,
    dept.value:LOC::varchar(20) as loc
  from dept2,
  lateral flatten(input => dept2.v, path => 'data') dept

select * from dept22

alter table dept22 add primary key (deptno);

select GET_DDL('TABLE', 'DEPT22');
create or replace TABLE DEPT22 (
	DEPTNO NUMBER(2,0),
	DNAME VARCHAR(20),
	LOC VARCHAR(20),
	primary key (DEPTNO)
);

alter table emp2 add foreign key (deptno) references dept22(deptno);
select GET_DDL('TABLE', 'EMP2');
create or replace TABLE EMP2 (
	EMPNO NUMBER(4,0) NOT NULL,
	ENAME VARCHAR(20) NOT NULL,
	JOB VARCHAR(20),
	MGR NUMBER(4,0),
	HIREDATE DATE,
	SAL FLOAT,
	COMM FLOAT,
	DEPTNO NUMBER(2,0) NOT NULL,
	unique (ENAME),
	primary key (EMPNO),
	foreign key (DEPTNO) references EMPLOYEES.PUBLIC.DEPT22(DEPTNO)
);

select e.*, d.*
from emp2 e left join dept22 d on e.deptno = d.deptno;
