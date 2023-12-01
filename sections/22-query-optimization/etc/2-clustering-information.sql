-- snowflake_sample_data.tpcds_sf100tcl.store_sales has ~300 B rows
-- select system$clustering_information(...) --> single JSON cell

use schema snowflake_sample_data.tpcds_sf100tcl;
alter session set use_cached_result = false;

show tables;

select count(*) from store_sales
  where ss_sold_date_sk = 2451227
  and ss_item_sk = 293752;

-- on the default full (multi-column) clustering key: ss_sold_date_sk, ss_item_sk
select system$clustering_information(
  'snowflake_sample_data.tpcds_sf100tcl.store_sales');

/*
{
  "cluster_by_keys" : "LINEAR(  ss_sold_date_sk, ss_item_sk  )",
  "total_partition_count" : 721507,
  "total_constant_partition_count" : 9,      so-so (higher is better)
  "average_overlaps" : 3.4849,               bad (many overlaps)
  "average_depth" : 2.7497,                  system$clustering_depth
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 3,
    "00002" : 180604,                        so-so (most on depth 2-3)
    "00003" : 540900,
    "00004" : 0,
    ...
    "00016" : 0                             good (none so deep)
  },
  "clustering_errors" : [ ]
}*/

select count(*) from store_sales
  where ss_sold_date_sk = 2451227;

-- on partial clustering key (first column only!)
select system$clustering_information(
  'snowflake_sample_data.tpcds_sf100tcl.store_sales',
  '(ss_sold_date_sk)');

/*
{
  "cluster_by_keys" : "LINEAR(ss_sold_date_sk)",
  "total_partition_count" : 721507,
  "total_constant_partition_count" : 719687,     good! (high)
  "average_overlaps" : 0.0132,                   good! (low)
  "average_depth" : 1.0076,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 719203,                            good! (most w/ depth 1)
    "00002" : 366,
    "00003" : 1197,
    "00004" : 624,
    "00005" : 78,
    "00006" : 17,
    ...
    "00032" : 22                                 so-so (22 partitions on depth 32)
  },
  "clustering_errors" : [ ]
}
*/

select count(*) from store_sales
  where ss_store_sk = 1136;

select count(*) from store_sales
  where ss_sold_date_sk = 2451227
    and ss_store_sk = 1136;

-- worst case scenario
select system$clustering_information(
  'snowflake_sample_data.tpcds_sf100tcl.store_sales',
  '(ss_store_sk)');

/*
{
  "cluster_by_keys" : "LINEAR(ss_store_sk)",
  "total_partition_count" : 721507,
  "total_constant_partition_count" : 0,        very bad (no constant partition)
  "average_overlaps" : 721506.0,               very bad (almost all overlap)
  "average_depth" : 721507.0,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 0,
    ...
    "1048576" : 721507
  },
  "clustering_errors" : [ ]
}
*/
