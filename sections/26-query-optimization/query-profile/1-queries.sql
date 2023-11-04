-- see https://medium.com/snowflake/how-to-make-your-own-snowflake-query-profile-8b93d58e4674

-- run this query (20.2K rows returned) and get its ID
select c_name, c_custkey, o_orderkey, o_orderdate, o_totalprice, sum(l_quantity)
from snowflake_sample_data.tpch_sf1.customer
  inner join snowflake_sample_data.tpch_sf1.orders on c_custkey = o_custkey
  inner join snowflake_sample_data.tpch_sf1.lineitem on o_orderkey = l_orderkey
where o_orderkey in (
  select l_orderkey from snowflake_sample_data.tpch_sf1.lineitem
  group by l_orderkey
  having sum(l_quantity) > 200) and o_orderdate >= '1997-01-01'
group by c_name, c_custkey, o_orderkey, o_orderdate, o_totalprice 
order by o_totalprice desc, o_orderdate;

-- run this recursive query and get its ID
with recursive cte (level, name, title, empno, mgr, path) as (
  select 1, ename, job, empno, mgr, ' -> ' || ename
  from employees.public.emp where mgr is null
  union all
  select m.level + 1,
    repeat('  ', level) || e.ename, e.job,
    e.empno, e.mgr, path || ' -> ' || e.ename
  from employees.public.emp e join cte m on e.mgr = m.empno)
select name, path, title from cte
order by path;

