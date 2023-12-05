# Section: Snowflake Native App Framework

## 1. Test locally as a Streamlit web app

* Customize your SnowSQL config file with my_conn as your Snowflake connection data (account and username are required).
* Save your password into a local SNOWSQL_PWD environment variable.
* Test with **`streamlit run app.py`** from the src subfolder.

## 2. Deploy and test as a local Snowflake native app in your own account

* Replace the *CRT_DIR* variable value in *deploy.sql* with your local path to these files.
* From the app/ folder, call **`snowsql -c my_conn -f deploy.sql`**. Make sure there are no red lines on screen.
* Start the app from Snowflake, from under the *Apps* folder. HIERARCHICAL_DATA_APP will show you the ReamMe file. Click on HIERARCHICAL_DATA_CODE to start the app.

## 3. Deploy as a private listing consumed by other accounts in your organization

* Create a *Provider Profile* in **Data > Provider Studio > Profiles**. Get it eventually approved for the Marketplace.
* Go to *Data > Private Sharing* and call **Share > Publish to Specified Consumers**.
    - add as title *Hierarchical Data Viewer*;
    - select *"Only Specified Consumer"*;
    - select HIERARCHICAL_DATA_PACKAGE to add in the listing;
    - enter *"Display your parent-child data pairs in a better manner."* as description;
    - add your consumer account (as <org_name>.<account_name>).

## 4. Consume the private listing from the other Snowflake account

* Got to the *Apps* folder, and you must see the shared package.
* Click on **Get**, and once again on the *Get* popup button.
* Once the app was installed, click on it, then go to HIERARCHICAL_DATA_CODE to run the app.

## 5. Consume the shared app with your own data

* Create a view that returns similar child-parent pairs, as our original employee-manager data.
* Grant our app read-only rights on this data with:
    **`GRANT USAGE on DATABASE db TO APPLICATION hierarchical_data_app;`**
    **`GRANT USAGE on SCHEMA db.schema TO APPLICATION hierarchical_data_app;`**
    **`GRANT SELECT on VIEW db.schema.name TO APPLICATION hierarchical_data_app;`**
* Restart the app, and replace the *employee* view name from our app with the full name of your view (*db.schema.view*). Click *Refresh* and you should see your own data!
