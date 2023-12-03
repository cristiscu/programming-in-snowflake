use schema employees.public;

select dname, sum(sal)
  from emp join dept on emp.deptno = dept.deptno
  where dname <> 'RESEARCH'
  group by dname
  order by dname;

explain
  select dname, sum(sal)
  from emp join dept on emp.deptno = dept.deptno
  where dname <> 'RESEARCH'
  group by dname
  order by dname;

select system$explain_plan_json(
$$
select dname, sum(sal)
  from emp join dept on emp.deptno = dept.deptno
  where dname <> 'RESEARCH'
  group by dname
  order by dname
$$);

/*
{
    "GlobalStats": {
        "partitionsTotal": 1,
        "partitionsAssigned": 1,
        "bytesAssigned": 1536
    },
    "Operations": [[
        {
            "id": 0,
            "operation": "Result",
            "expressions": [ "DEPT.DNAME", "SUM(EMP.SAL)" ]
        },{
            "id": 1,
            "operation": "Sort",
            "expressions": [ "DEPT.DNAME ASC NULLS LAST" ],
            "parentOperators": [ 0 ]
        },{
            "id": 2,
            "operation": "Aggregate",
            "expressions": [ "aggExprs: [SUM(EMP.SAL)]", "groupKeys: [DEPT.DNAME]" ],
            "parentOperators": [ 1 ]
        },{
            "id": 3,
            "operation": "InnerJoin",
            "expressions": [ "joinKey: (DEPT.DEPTNO = EMP.DEPTNO)" ],
            "parentOperators": [ 2 ]
        },{
            "id": 4,
            "operation": "Filter",
            "expressions": [ "DEPT.DNAME <> 'RESEARCH'" ],
            "parentOperators": [ 3 ]
        },{
            "id": 5,
            "operation": "TableScan",
            "objects": [ "EMPLOYEES.PUBLIC.DEPT" ],
            "expressions": [ "DEPTNO", "DNAME" ],
            "partitionsAssigned": 1,
            "partitionsTotal": 1,
            "bytesAssigned": 1536,
            "parentOperators": [ 4 ]
        },{
            "id": 6,
            "operation": "DynamicSecureView",
            "objects": [ "\"EMP (+ RowAccessPolicy)\"" ],
            "parentOperators": [ 3 ]
        }
    ]]
}
*/