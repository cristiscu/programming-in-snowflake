-- (1) create a dedicated S3 bucket with a data/ folder
-- (2) create a IAM access policy (in JSON, see below), w/ access to the S3 data/ folder
-- (3) attach the IAM policy to a new IAM user
-- (4) generate and copy access keys for the new IAM user
-- (5) upload data/emp11.csv and data/emp12.csv files
-- see https://docs.snowflake.com/en/user-guide/data-load-s3-config-aws-iam-user

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
            "Resource": "arn:aws:s3:::my-snowflake-bucket/data/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::my-snowflake-bucket",
            "Condition": { "StringLike": { "s3:prefix": [ "data/*" ] } }
        }
    ]
}
*/

-- establish context
use schema employees.public;

-- must customize w/ your own bucket name and access keys!
create or replace stage mystage_s3
  url = 's3://my-snowflake-bucket/data/'
  credentials = (
    aws_key_id='AKIAW6W....V123GTOIY'
    aws_secret_key='lRKEe0k....4123ZIJvXFxNqKYzasbQy8Fe9u2AE');

-- should see the uploaded CSV files from the S3 data/ folder
list @mystage_s3;

-- cleanup AWS resources and drop stage
drop stage mystage_s3;