-- creates and populates a public EMPLOYEES database
CREATE OR REPLACE DATABASE employees;

CREATE TABLE dept (
   deptno int PRIMARY KEY,
   dname varchar(20) NOT NULL,
   loc varchar(20) NOT NULL,
   UNIQUE (dname, loc));

INSERT INTO dept VALUES
  (10, 'ACCOUNTING', 'NEW YORK'),
  (20, 'RESEARCH', 'DALLAS'),
  (30, 'SALES', 'CHICAGO'),
  (40, 'OPERATIONS', 'BOSTON');

CREATE TABLE emp (
   empno int PRIMARY KEY,
   ename varchar(20) NOT NULL UNIQUE,
   job varchar(20) NOT NULL,
   mgr int,
   hiredate date NOT NULL,
   sal float NOT NULL,
   comm float,
   deptno int NOT NULL,
   FOREIGN KEY (mgr) REFERENCES emp (empno),
   FOREIGN KEY (deptno) REFERENCES dept (deptno));

INSERT INTO emp VALUES
  (7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10),
  (7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850, NULL, 30),
  (7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250, 1400, 30),
  (7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600, 300.50, 30),
  (7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 30),
  (7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950, NULL, 30),
  (7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500, 0, 30),
  (7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450.50, NULL, 10),
  (7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300, NULL, 10),
  (7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975.80, NULL, 20),
  (7788, 'SCOTT', 'ANALYST', 7566, '1982-12-09', 3000, NULL, 20),
  (7876, 'ADAMS', 'CLERK', 7788, '1983-01-12', 1100, NULL, 20),
  (7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000, NULL, 20),
  (7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800, NULL, 20);

CREATE TABLE proj (
   projid int PRIMARY KEY,
   empno int NOT NULL,
   startdate date NOT NULL,
   enddate date NOT NULL,
   FOREIGN KEY (empno) REFERENCES emp (empno));

INSERT INTO proj VALUES
  (1, 7782, '2005-06-16', '2005-06-18'),
  (4, 7782, '2005-06-19', '2005-06-24'),
  (7, 7782, '2005-06-22', '2005-06-25'),
  (10, 7782, '2005-06-25', '2005-06-28'),
  (13, 7782, '2005-06-28', '2005-07-02'),
  (2, 7839, '2005-06-17', '2005-06-21'),
  (8, 7839, '2005-06-23', '2005-06-25'),
  (14, 7839, '2005-06-29', '2005-06-30'),
  (11, 7839, '2005-06-26', '2005-06-27'),
  (5, 7839, '2005-06-20', '2005-06-24'),
  (3, 7934, '2005-06-18', '2005-06-22'),
  (12, 7934, '2005-06-27', '2005-06-28'),
  (15, 7934, '2005-06-30', '2005-07-03'),
  (9, 7934, '2005-06-24', '2005-06-27'),
  (6, 7934, '2005-06-21', '2005-06-23');
