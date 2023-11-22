# Section: Loading and Accessing CSV Data

## [Prepare S3 Folder as Snowflake External Stage](https://docs.snowflake.com/en/user-guide/data-load-s3-config-aws-iam-user)

1. In your AWS account, create a dedicated **S3 bucket** with a *data/* folder.
2. Upload *data/emp11.csv* and *data/emp12.csv* files.
3. Create a **IAM access policy** to access your S3 folder (customize JSON below).
4. Attach the IAM policy to a new **IAM user**.
5. Generate and copy the two **access keys** for the new IAM user.

```
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
```
