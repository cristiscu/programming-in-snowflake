-- establish context
use schema data_pipelines.public;

-- after you create a dedicated S3 bucket with a folder, and upload some CSV files
-- must also create a IAM access policy (w/ read access on the S3 folder)
-- and attach it to a new IAM user, for whom you generate and copy access keys

/*
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
            ],
            "Resource": "arn:aws:s3:::snowflake-demo-8888/spool/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::snowflake-demo-8888",
            "Condition": { "StringLike": { "s3:prefix": [ "spool/*" ] } }
        }
    ]
}
*/

-- must customize w/ your own bucket name and access keys!
create or replace stage mystage_s3
  url = 's3://snowflake-demo-8888/spool/'
  credentials = (
    aws_key_id='AKIAW6WN772VQZAO3OIY'
    aws_secret_key='lRKEe0kaSkV4a5IZIJvXFxNqKYzasbQy8Fe9u2AE');

-- should see the uploaded CSV files from the S3 bucket/folders
list @mystage_s3;


  
