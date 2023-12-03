-- run query twice and check second time it was from cache
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

select * from table(result_scan(last_query_id()));

show tables;
select * from table(result_scan(last_query_id()));

alter session set use_cached_result = false;
-- check again query result is NOT from cache

-- query profile steps
-- see https://medium.com/snowflake/how-to-make-your-own-snowflake-query-profile-8b93d58e4674
select * from table(
  get_query_operator_stats(last_query_id()))