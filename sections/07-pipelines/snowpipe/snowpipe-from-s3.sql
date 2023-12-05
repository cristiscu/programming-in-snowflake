use schema employees.public;

-- create an empty external S3 stage as described in the CSV section
-- customize with your own bucket name and user access keys
create or replace stage mystage_s3
  url = 's3://your-bucket-name/data/'
  credentials = (
    aws_key_id='AKIA..........MPBFUM'
    aws_secret_key='tuezr/yX/xbnq.........Or3c7dZzCmyA5PmHo');

-- should be empty
list @mystage_s3;

create table emp_pipe like emp;

-- PURGE not supported!
create pipe mypipe
  auto_ingest = true
as
  copy into emp_pipe from @mystage_s3
    file_format = (type = 'CSV')
    on_error = 'CONTINUE';

-- copy the SQS ARN (notification_channel column) and paste it in the AWS S3 event configuration
-- ex: arn:aws:sqs:us-west-2:946158320428:sf-snowpipe-AIDA5YS3OHMWLDQF7M7ML-DXU1ig_rWZl_kGj1DUnL9Q
show pipes;

-- add an event notification in the S3 bucket, for spool/ directory
-- for "All object create events", w/ SNS Queue as ARN previously copied

-- upload some CSV files in the folder
select system$pipe_status('mypipe');
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

select * from emp_pipe;

alter pipe mypipe
  set pipe_execution_paused = true;

-- cleanup AWS resources (S3 bucket, user, policy) and drop stage
-- drop stage mystage_s3;