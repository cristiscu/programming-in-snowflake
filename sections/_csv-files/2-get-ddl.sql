-- recreate EMP table w/ DDL definition and some constraints
use schema employees.public;

select GET_DDL('TABLE', 'EMP');
create or replace TABLE EMP (
	EMPNO NUMBER(4,0) PRIMARY KEY,
	ENAME VARCHAR(20) NOT NULL UNIQUE,
	JOB VARCHAR(20),
	MGR NUMBER(4,0),
	HIREDATE DATE,
	SAL float,
	COMM float,
	DEPTNO NUMBER(2,0) NOT NULL
);

COPY INTO EMP FROM @mystage
   FILES = ('emp.csv')
   FILE_FORMAT = (FORMAT_NAME = mycsvformat)
   MATCH_BY_COLUMN_NAME = CASE_SENSITIVE
   FORCE = TRUE;

select * from emp;
