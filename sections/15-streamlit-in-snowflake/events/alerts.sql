-- select context
use schema employees.public;

-- create email notification integration (to be able to call SEND_EMAIL())
-- (replace w/ your own account email address!)
CREATE NOTIFICATION INTEGRATION myemail
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('your-email@icloud.com');

-- manually send an email (replace w/ your own email address!)
CALL SYSTEM$SEND_EMAIL(
  'myemail',
  'your-email@icloud.com',
  'Email Alert: This is a test.',
  'The task has successfully finished.\nEnd Time: 12:15:45');

-- check every minute and send email if we have a department w/ ID too large
CREATE OR REPLACE ALERT myalert
  WAREHOUSE = compute_wh
  SCHEDULE = '1 minute'
  IF(EXISTS(SELECT deptno FROM dept WHERE deptno > 10000))
  THEN CALL SYSTEM$SEND_EMAIL(
    'myemail',
    'your-email@icloud.com',
    'Email Alert: Wrong Department Number.',
    'A value too large has been entered for the department ID.\nCheck the DEPT table!');

ALTER ALERT myalert RESUME;

-- create alert condition
INSERT INTO dept VALUES (14000, 'Wrong Dept Value', 'Toronto');
INSERT INTO dept VALUES (16000, 'Another Wrong Value', 'Vancouver');

ALTER ALERT myalert SUSPEND;

-- should show two entries, after 1-2 minutes
select * from table(INFORMATION_SCHEMA.ALERT_HISTORY());

-- remove inserted rows
DELETE FROM dept WHERE deptno > 10000;
SELECT * FROM dept;

-- cleanup
DROP NOTIFICATION INTEGRATION myemail;
DROP ALERT myalert;
