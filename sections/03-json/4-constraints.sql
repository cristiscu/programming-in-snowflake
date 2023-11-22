-- select context
use schema employees.public;

-- add PK constraint to DEPT table
alter table dept
  add primary key (deptno);

select GET_DDL('TABLE', 'DEPT');
create TABLE dept (
	DEPTNO NUMBER(2,0),
	DNAME VARCHAR(20),
	LOC VARCHAR(20),
	primary key (DEPTNO)
);

-- add FK constraint to EMP table
alter table emp
  add foreign key (deptno) references dept (deptno);

select GET_DDL('TABLE', 'EMP');
create table EMP (
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
