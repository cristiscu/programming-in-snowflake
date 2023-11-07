-- assuming we already created a mystage_s3 external S3 stage
-- for the s3://snowflake-demo-8888/spool/ bucket folder
-- delete all previously loaded CSV files in the folder

-- establish context
use schema employees.public;

-- create test target table
create or replace table emp_s3 (
   empno int,
   ename varchar,
   job varchar,
   mgr int,
   hiredate date,
   sal float,
   comm float,
   deptno int);

create pipe mypipe_s3
  auto_ingest = true
as
  copy into emp_s3 from @mystage_s3
    file_format = (type = 'CSV')
    on_error = 'CONTINUE';

-- copy the SQS ARN to paste in AWS S3 event configuration
-- ex: arn:aws:sqs:us-west-2:946158320428:sf-snowpipe-AIDA5YS3OHMWLDQF7M7ML-DXU1ig_rWZl_kGj1DUnL9Q
show pipes;

-- add an event notification in the S3 bucket, for spool/ directory
-- for "All object create events", w/ SNS Queue as ARN previously copied

-- upload some CSV files in the folder
select system$pipe_status('mypipe_s3');
/*
{
    "executionState": "RUNNING",
    "pendingFileCount": 0,
    "lastIngestedTimestamp": "2023-11-07T01:28:58.157Z",
    "lastIngestedFilePath": "emp12.csv",
    "notificationChannelName": "arn:aws:sqs:us-west-2:946158320428:sf-snowpipe-AIDA5YS3OHMWLDQF7M7ML-DXU1ig_rWZl_kGj1DUnL9Q",
    "numOutstandingMessagesOnChannel": 2,
    "lastReceivedMessageTimestamp": "2023-11-07T01:28:58.01Z",
    "lastForwardedMessageTimestamp": "2023-11-07T01:28:58.286Z",
    "lastPulledFromChannelTimestamp": "2023-11-07T01:30:07.993Z",
    "lastForwardedFilePath": "snowflake-demo-8888/spool/emp12.csv"
}
*/

  
