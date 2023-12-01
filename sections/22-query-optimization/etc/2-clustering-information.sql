-- snowflake_sample_data.tpcds_sf100tcl.store_sales has ~300 B rows
-- select system$clustering_information(...) --> single JSON cell

select system$clustering_information(
  'snowflake_sample_data.tpcds_sf100tcl.store_sales');

/*
{
  "cluster_by_keys" : "LINEAR(  ss_sold_date_sk, ss_item_sk  )",
  "total_partition_count" : 721507,
  "total_constant_partition_count" : 9,
  "average_overlaps" : 3.4849,
  "average_depth" : 2.7497,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 3,
    "00002" : 180604,
    "00003" : 540900,
    "00004" : 0,
    "00005" : 0,
    "00006" : 0,
    "00007" : 0,
    "00008" : 0,
    "00009" : 0,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0
  },
  "clustering_errors" : [ ]
}*/

select system$clustering_information(
  'snowflake_sample_data.tpcds_sf100tcl.store_sales',
  '(ss_sold_date_sk)');

/*
{
  "cluster_by_keys" : "LINEAR(ss_sold_date_sk)",
  "total_partition_count" : 721507,
  "total_constant_partition_count" : 719687,
  "average_overlaps" : 0.0132,
  "average_depth" : 1.0076,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 719203,
    "00002" : 366,
    "00003" : 1197,
    "00004" : 624,
    "00005" : 78,
    "00006" : 17,
    "00007" : 0,
    "00008" : 0,
    "00009" : 0,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0,
    "00032" : 22
  },
  "clustering_errors" : [ ]
}
*/

select system$clustering_information(
  'snowflake_sample_data.tpcds_sf100tcl.store_sales',
  '(ss_store_sk)');

/*
{
  "cluster_by_keys" : "LINEAR(ss_store_sk)",
  "total_partition_count" : 721507,
  "total_constant_partition_count" : 0,
  "average_overlaps" : 721506.0,
  "average_depth" : 721507.0,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 0,
    "00002" : 0,
    "00003" : 0,
    "00004" : 0,
    "00005" : 0,
    "00006" : 0,
    "00007" : 0,
    "00008" : 0,
    "00009" : 0,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0,
    "1048576" : 721507
  },
  "clustering_errors" : [ ]
}
*/
