-- select database and schema
use schema employees.public;

-- (1) Extract semantic categories (after CUSTOMERS_FAKE created w/ Faker)
SELECT EXTRACT_SEMANTIC_CATEGORIES('CUSTOMERS_FAKE');

/*
{
  "ADDRESS": { "alternates": [] },
  "CITY": { "alternates": [] },
  "EMAIL": {
    "alternates": [],
    "recommendation": {
      "confidence": "HIGH",
      "coverage": 1,
      "details": [],
      "privacy_category": "IDENTIFIER",
      "semantic_category": "EMAIL"
    },
    "valid_value_ratio": 1
  },
  "NAME": {
    "alternates": [],
    "recommendation": {
      "confidence": "HIGH",
      "coverage": 0.9994,
      "details": [],
      "privacy_category": "IDENTIFIER",
      "semantic_category": "NAME"
    },
    "valid_value_ratio": 1
  },
  "STATE": {
    "alternates": [],
    "recommendation": {
      "confidence": "HIGH",
      "coverage": 1,
      "details": [{ "coverage": 1, "semantic_category": "US_STATE_OR_TERRITORY" }],
      "privacy_category": "QUASI_IDENTIFIER",
      "semantic_category": "ADMINISTRATIVE_AREA_1"
    },
    "valid_value_ratio": 1
  }
}
*/

SELECT f.key::varchar as column_name,
  f.value:"recommendation":"privacy_category"::varchar as privacy_category,
  f.value:"recommendation":"semantic_category"::varchar as semantic_category,
  f.value:"recommendation":"confidence"::varchar as confidence,
  f.value:"recommendation":"coverage"::number(10,2) as coverage,
  f.value:"details"::variant as details,  f.value:"alternates"::variant as alts
FROM TABLE(FLATTEN(EXTRACT_SEMANTIC_CATEGORIES('CUSTOMERS_FAKE')::VARIANT)) AS f;

-- adjust categories in this temp table!
CREATE TEMPORARY TABLE semantic_categories(v VARIANT) AS
  SELECT EXTRACT_SEMANTIC_CATEGORIES('EMPLOYEES.PUBLIC.CUSTOMERS_FAKE');

-- (2) Apply semantic categories
CALL ASSOCIATE_SEMANTIC_CATEGORY_TAGS(
  'EMPLOYEES.PUBLIC.CUSTOMERS_FAKE',
  (SELECT * FROM semantic_categories));
-- --> Applied tag semantic_category to 3 columns. Applied tag privacy_category to 3 columns.

/*
-- alternative: directly
CALL ASSOCIATE_SEMANTIC_CATEGORY_TAGS(
  'EMPLOYEES.PUBLIC.CUSTOMERS_FAKE',
  EXTRACT_SEMANTIC_CATEGORIES('EMPLOYEES.PUBLIC.CUSTOMERS_FAKE'));

*/

-- (3) Track the applied system tags

-- PRIVACY_CATEGORY and SEMANTIC_CATEGORY tags are defined in SNOWFLAKE.CORE
SHOW TAGS in schema SNOWFLAKE.CORE;
SHOW TAGS IN ACCOUNT;

-- not listed here (by def in crt database and schema!)
-- see https://community.snowflake.com/s/article/No-TAGS-visible-in-ACCOUNT-USAGE-TAGS-after-using-the-stored-procedure-ASSOCIATE-SEMANTIC-CATEGORY-TAGS
SHOW TAGS;

-- EMAIL column shows both PRIVACY_CATEGORY and SEMANTIC_CATEGORY tags
select * from table(
  information_schema.tag_references(
    'EMPLOYEES.PUBLIC.CUSTOMERS_FAKE.EMAIL', 'column'));

-- show all columns w/ tags in the table
select * from table(
  information_schema.tag_references_all_columns(
    'EMPLOYEES.PUBLIC.CUSTOMERS_FAKE', 'table'));

-- returns nothing
select * from table(
  snowflake.account_usage.tag_references_with_lineage(
    'SNOWFLAKE.CORE.PRIVACY_CATEGORY'));

-- returns all columns w/ tag (even if tags not defined in the account!)
select * from snowflake.account_usage.tag_references;

-- retuns nothing (as sensitive tags not defined in this account)
select * from snowflake.account_usage.tags;

-- returns IDENTIFIER
select SYSTEM$GET_TAG(
  'SNOWFLAKE.CORE.PRIVACY_CATEGORY',
  'EMPLOYEES.PUBLIC.CUSTOMERS_FAKE.EMAIL',
  'column')
