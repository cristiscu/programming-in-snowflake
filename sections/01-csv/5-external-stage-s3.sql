-- establish context
use schema data_pipelines.public;

-- after you create a dedicated S3 bucket with a folder, and upload some CSV files
-- must also create a IAM access policy (w/ read access on the S3 folder)
-- and attach it to a new IAM user, for whom you generate and copy access keys
create or replace stage mystage_s3
  url = 's3://snowflake-demo-8888/spool/'
  credentials = (
    aws_key_id='AKIAW6WN772VQZAO3OIY'
    aws_secret_key='lRKEe0kaSkV4a5IZIJvXFxNqKYzasbQy8Fe9u2AE');

-- should see the uploaded CSV files from the S3 bucket/folders
list @mystage_s3;


  
