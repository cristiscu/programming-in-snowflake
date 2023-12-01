import modules.utils as utils

class QueryAnalyzer:

    msg = ""
    queryId = None
    queryText = ""
    props = {}
    isAccountUsage = False

    def __init__(self, queryId) -> None:
        self.queryId = queryId
            
    def _sizeof_fmt(self, num, suffix = ""):
        orig_num = num
        suffix_bytes = f" ({orig_num} bytes)"
        for unit in [" bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB"]:
            if abs(num) < 1024.0:
                s = f"{num:3.1f}{unit}{suffix}"
                return s if num == orig_num else s + suffix_bytes
            num /= 1024.0
        s = f"{num:.1f}Yi{suffix}"
        return s if num == orig_num else s + suffix_bytes

    # check number of execs in the past month
    def _checkExecNumber(self):
        rows = utils.runQuery(
            "SELECT sum(TOTAL_ELAPSED_TIME) / 1000 as TOTAL_TIME_SECONDS, "
            "count(*) as NUMBER_OF_CALLS "
            "from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY "
            f"where QUERY_TEXT = '{self.queryText}' "
            "and TO_DATE(START_TIME) > DATEADD(month, -1, TO_DATE(CURRENT_TIMESTAMP()))")
        if len(rows) == 0:
            self.msg += "It has not been executed at all in the last month.\n"
            return 0
        else:
            row = rows[0]
            self.msg += f"It has been executed {row[1]} times in the last month, for a total of {row[0]} seconds.\n"
            return int(row[1])

    # among top N most frequently used queries?
    def _isFrequentQuery(self, n):
        rows = utils.runQuery(
            "with topFrequent as ( "
            "select case when not contains(QUERY_TEXT, '-- Looker Query Context') then QUERY_TEXT "
            "else left(QUERY_TEXT, position('-- Looker Query Context' in QUERY_TEXT)) end as query_text_cut "
            "from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY "
            "where TO_DATE(START_TIME) > DATEADD(month, -1, TO_DATE(CURRENT_TIMESTAMP())) "
            "and TOTAL_ELAPSED_TIME > 0 "
            "group by 1 "
            "having count(*) >= 2 "
            "order by count(*) desc "
            f"LIMIT {n}) "
            "select query_text_cut from topFrequent "
            f"where query_text_cut = '{self.queryText}'")
        if len(rows) == 0:
            self.msg += f"It is NOT among the top {n} most frequent queries executed in the last month.\n"
            return False
        else:
            self.msg += f"It is among the top {n} most frequent queries executed in the last month.\n"
            return True

    # among top N longest queries?
    def _isLongestQuery(self, n):
        rows = utils.runQuery(
            "with topLongest as ( "
            "select QUERY_TEXT "
            "from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY "
            "where TO_DATE(START_TIME) > DATEADD(month, -1, TO_DATE(CURRENT_TIMESTAMP())) "
            "and TOTAL_ELAPSED_TIME > 0 "
            "and ERROR_CODE iS NULL "
            "and PARTITIONS_SCANNED is not null "
            "group by query_text "
            "order by avg(TOTAL_ELAPSED_TIME) desc "
            f"LIMIT {n}) "
            "select query_text from topLongest "
            f"where query_text = '{self.queryText}'")
        if len(rows) == 0:
            self.msg += f"It is NOT among the top {n} longest queries executed in the last month.\n"
            return False
        else:
            self.msg += f"It is among the top {n} longest queries executed in the last month.\n"
            return True

    # among top N with most scanned data?
    def _isHeavyQuery(self, n):
        rows = utils.runQuery(
            "with topScanned as ( "
            "select QUERY_TEXT "
            "from SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY "
            "where TO_DATE(START_TIME) > DATEADD(month, -1, TO_DATE(CURRENT_TIMESTAMP())) "
            "and TOTAL_ELAPSED_TIME > 0 "
            "and ERROR_CODE iS NULL "
            "and PARTITIONS_SCANNED is not null "
            "group by query_text "
            "order by avg(BYTES_SCANNED) desc "
            f"LIMIT {n}) "
            "select query_text from topScanned "
            f"where query_text = '{self.queryText}'")
        if len(rows) == 0:
            self.msg += f"It is NOT among the top {n} queries with most data scanned executed in the last month.\n"
            return False
        else:
            self.msg += f"It is among the top {n} queries queries with most data scanned executed in the last month.\n"
            return True

    # Display info from QUERY_HISTORY, from either ACCOUNT_USAGE or INFORMATION_SCHEMA
    def showQueryHistory(self):

        # query execution
        if self.props['EXECUTION_STATUS'] != 'SUCCESS':
            self.msg += f"\nThe query failed with error code {self.props['ERROR_CODE']}: {self.props['ERROR_MESSAGE']}\n"
        else:
            self.msg += (f"\nThe query has been run successfully in {self.props['TOTAL_ELAPSED_TIME']:,} ms: "
                f"it compiled in {self.props['COMPILATION_TIME']:,} ms "
                f"+ it executed in {self.props['EXECUTION_TIME']:,} ms.\n")
            self.msg += f"The query run between {self.props['START_TIME']} and {self.props['END_TIME']}.\n"

            if self.isAccountUsage:
                self.msg += "\n"

                # check number of calls in the past month
                if self._checkExecNumber() > 1:
                    self._isFrequentQuery(10)

                # among top 10 or 100 longest queries?
                if self._isLongestQuery(10) == False:
                    self._isLongestQuery(100)

                # among top 10 or 100 with most scanned data?
                if self._isHeavyQuery(10) == False:
                    self._isHeavyQuery(100)

        # user/role/database/schema context
        self.msg += f"\nThe query was executed by the {self.props['USER_NAME']} user, using the {self.props['ROLE_NAME']} role.\n"

        if self.props['DATABASE_NAME'] != None and self.props['SCHEMA_NAME'] != None:
            self.msg += f"The query was executed within the {self.props['DATABASE_NAME']}.{self.props['SCHEMA_NAME']} database and schema context.\n"

        # warehouse + credit
        wh_size = (f"{self.props['WAREHOUSE_SIZE']} "
            if self.props['WAREHOUSE_SIZE'] != None
            else "")
        load_percent = (f"{self.props['QUERY_LOAD_PERCENT']}% of resources available, "
            if self.isAccountUsage and 'QUERY_LOAD_PERCENT' in self.props and self.props['QUERY_LOAD_PERCENT'] != None
            else "")
        nodes = (f"with {self.props['CLUSTER_NUMBER']} nodes, "
            if self.props['CLUSTER_NUMBER'] != None
            else "")
        self.msg += (f"The query used the {wh_size}{self.props['WAREHOUSE_NAME']} "
            f"{self.props['WAREHOUSE_TYPE'].lower()} warehouse, {nodes}{load_percent}"
            f"with {self.props['CREDITS_USED_CLOUD_SERVICES']} cloud compute credits.\n")

        # results
        if self.props['ROWS_PRODUCED'] == None:
            self.msg += f"\nThe query produced no rows.\n"
        else:
            self.msg += f"\nThe query produced {self.props['ROWS_PRODUCED']} rows.\n"

        if 'ROWS_INSERTED' in self.props and int(self.props['ROWS_INSERTED']) > 0:
            self.msg += f"{self.props['ROWS_INSERTED']} rows have been inserted, for a total of {self._sizeof_fmt(self.props['BYTES_WRITTEN'])}.\n"
        if 'ROWS_DELETED' in self.props and int(self.props['ROWS_DELETED']) > 0:
            self.msg += f"{self.props['ROWS_DELETED']} rows have been deleted, for a total of {self._sizeof_fmt(self.props['BYTES_DELETED'])}.\n"
        if 'ROWS_UPDATED' in self.props and int(self.props['ROWS_UPDATED']) > 0:
            self.msg += f"{self.props['ROWS_UPDATED']} rows have been updated.\n"
        if 'ROWS_UNLOADED' in self.props and int(self.props['ROWS_UNLOADED']) > 0:
            self.msg += f"{self.props['ROWS_UNLOADED']} rows have been unloaded.\n"

        # query queued
        if int(self.props["QUEUED_PROVISIONING_TIME"]) > 0:
            self.msg += (f"\nThe query has been queued for {self.props['QUEUED_PROVISIONING_TIME']} ms, "
                f"waiting for the warehouse to provision, due to the warehouse creation, resume, or resize.\n")
        if int(self.props["QUEUED_REPAIR_TIME"]) > 0:
            self.msg += (f"\nThe query has been queued for {self.props['QUEUED_REPAIR_TIME']} ms, "
                f"waiting for compute resources in the warehouse to be repaired.\n")
        if int(self.props["QUEUED_OVERLOAD_TIME"]) > 0:
            self.msg += (f"\nThe query has been queued for {self.props['QUEUED_OVERLOAD_TIME']} ms, "
                f"due to the warehouse being overloaded by the current query workload.\n")

        if int(self.props["TRANSACTION_BLOCKED_TIME"]) > 0:
            self.msg += f"\nThe query has been blocked for {self.props['TRANSACTION_BLOCKED_TIME']} ms by transactions.\n"

        if 'BYTES_SPILLED_TO_LOCAL_STORAGE' in self.props:
            if int(self.props["BYTES_SPILLED_TO_LOCAL_STORAGE"]) >= 1000000:
                self.msg += (f"\nOver 1MB - {self._sizeof_fmt(self.props['BYTES_SPILLED_TO_LOCAL_STORAGE'])} - spilled to local storage. "
                    "\nThis could mean that your warehouse nodes do not have enough RAM. "
                    "They have to do swap with the local SSD disk too frequently. "
                    "\nHint: You may need a larger warehouse.\n")
            elif int(self.props["BYTES_SPILLED_TO_LOCAL_STORAGE"]) == 0:
                self.msg += ("\nNothing spilled to local storage, which is good. "
                "\nThis often means that the warehouse node(s) had enough memory to process it all in RAM.\n")
            else:
                self.msg += f"\n{self._sizeof_fmt(self.props['BYTES_SPILLED_TO_LOCAL_STORAGE'])} spilled to local storage.\n"

        if 'BYTES_SPILLED_TO_REMOTE_STORAGE' in self.props:
            if int(self.props["BYTES_SPILLED_TO_REMOTE_STORAGE"]) >= 1000000:
                self.msg += (f"\nOver 1MB - {self._sizeof_fmt(self.props['BYTES_SPILLED_TO_REMOTE_STORAGE'])} - spilled to remote storage. "
                    "\nThis could mean that your warehouse nodes do not have large enough SSD disks. "
                    "The query had to access way to frequently the remote S3 or Azure Blog storage. "
                    "\nYou may need a larger warehouse.\n")
            elif int(self.props["BYTES_SPILLED_TO_REMOTE_STORAGE"]) == 0:
                self.msg += ("\nNothing spilled to remote storage, which is good. "
                "\nThis often means that the warehouse node(s) had enough RAM and SSD disk space to process it all locally.\n")
            else:
                self.msg += f"\n{self._sizeof_fmt(self.props['BYTES_SPILLED_TO_REMOTE_STORAGE'])} spilled to remote storage.\n"
            self.msg += "See https://community.snowflake.com/s/article/Performance-impact-from-local-and-remote-disk-spilling.\n"

        if 'BYTES_SCANNED' in self.props:
            self.msg += f"\nThe query scanned a total of {self._sizeof_fmt(self.props['BYTES_SCANNED'])}.\n"
            if int(self.props['BYTES_SCANNED']) > 10000000:
                self.msg += "Hint: Consider reducing the amount of data a query needs to read from the tables.\n"
                #self.msg += "See .")

        if 'PERCENTAGE_SCANNED_FROM_CACHE' in self.props:
            if float(self.props['PERCENTAGE_SCANNED_FROM_CACHE']) == 1.0:
                self.msg += ("\nAll your data has been served from the result cache, "
                    "so the query did not execute again, and did not consume any compute resources. "
                    "\nThis is great! The query result will still be here for at least 24 hours."
                    "\nSee https://community.snowflake.com/s/article/Understanding-Result-Caching.\n")
            elif float(self.props['PERCENTAGE_SCANNED_FROM_CACHE']) > 0.8:
                self.msg += (f"\nMore than 80% ({self.props['PERCENTAGE_SCANNED_FROM_CACHE']}) of your data has been found in the result cache. "
                    "This is good.\n")
            elif float(self.props['PERCENTAGE_SCANNED_FROM_CACHE']) < 0.5:
                self.msg += (f"\nLess than 5% ({self.props['PERCENTAGE_SCANNED_FROM_CACHE']}) of your data has been found in the result cache. "
                    "\nHint: Look for consecutive queries that could use the query result cache."
                    "\nSee https://community.snowflake.com/s/article/Understanding-Result-Caching.\n")
            else:
                self.msg += (f"\n{self.props['PERCENTAGE_SCANNED_FROM_CACHE']} of your data has been found in the result cache."
                    "\nSee https://community.snowflake.com/s/article/Understanding-Result-Caching for more info.\n")

        # partitions and pruning
        if ('PARTITIONS_SCANNED' in self.props
            and 'PARTITIONS_TOTAL' in self.props
            and int(self.props['PARTITIONS_TOTAL']) > 0):
            if int(self.props['PARTITIONS_SCANNED']) == int(self.props['PARTITIONS_TOTAL']):
                self.msg += (f"\nYou had a full table scan, for all {self.props['PARTITIONS_TOTAL']:,} partitions. "
                    "\nHint: Consider improving partition pruning, by eventually adding some cluster key, or a filter.\n")
            elif int(self.props['PARTITIONS_SCANNED']) <= 0.2 * int(self.props['PARTITIONS_TOTAL']):
                self.msg += (f"\n{self.props['PARTITIONS_SCANNED']:,} partitions out of a total of {self.props['PARTITIONS_TOTAL']:,} have been scanned. "
                    "\nPartition pruning (and your current cluster keys) seem efficient for this query.\n")
            else:
                self.msg += (f"\n{self.props['PARTITIONS_SCANNED']:,} partitions out of a total of {self.props['PARTITIONS_TOTAL']:,} have been scanned. "
                    "\nHint: Consider improving partition pruning, by eventually adding some cluster key, or a filter.\n")

            self.msg += "See https://community.snowflake.com/s/article/How-to-recognize-unsatisfactory-pruning.\n"

        # inbound/outbound
        if int(self.props['INBOUND_DATA_TRANSFER_BYTES']) > 0:
            self.msg += (f"\nThe query received {self._sizeof_fmt(self.props['INBOUND_DATA_TRANSFER_BYTES'])} "
                f"from the {self.props['INBOUND_DATA_TRANSFER_CLOUD=None']} inbound acount, "
                f"in the {self.props['INBOUND_DATA_TRANSFER_REGION']} region.\n")
        if int(self.props['OUTBOUND_DATA_TRANSFER_BYTES']) > 0:
            self.msg += (f"\nThe query sent {self._sizeof_fmt(self.props['OUTBOUND_DATA_TRANSFER_BYTES'])} "
                f"to the {self.props['OUTBOUND_DATA_TRANSFER_CLOUD=None']} outbound acount, "
                f"in the {self.props['OUTBOUND_DATA_TRANSFER_REGION']} region.\n")

        # external functions
        if int(self.props['EXTERNAL_FUNCTION_TOTAL_INVOCATIONS']) > 0:
            self.msg += (f"\nYour query called {self.props['EXTERNAL_FUNCTION_TOTAL_INVOCATIONS']} times external functions. "
                f"\n{self.props['EXTERNAL_FUNCTION_TOTAL_SENT_ROWS']} rows have been send, {self.props['EXTERNAL_FUNCTION_TOTAL_RECEIVED_ROWS']} rows received. "
                f"\n{self._sizeof_fmt(self.props['EXTERNAL_FUNCTION_TOTAL_SENT_BYTES'])} have been send, {self._sizeof_fmt(self.props['EXTERNAL_FUNCTION_TOTAL_RECEIVED_BYTES'])} received.\n")

    # look in account_usage by query ID
    def _inAccountUsageById(self):

        rows = utils.runQuery(
            "select top 1 * "
            + "from snowflake.account_usage.query_history "
            + f"where query_id = '{self.queryId}'")
        if len(rows) > 0:
            self.msg += "The query was found by ID in the ACCOUNT_USAGE schema.\n"
            return rows[0]
        else:
            self.msg += "The query (by ID) is not in the ACCOUNT_USAGE schema yet. Trying the INFORMATION_SCHEMA instead...\n"
            return None

    # look in information_schema by query ID
    def _inInformationSchemaById(self):

        rows = utils.runQuery(
            "select top 1 * "
            + "from table(snowflake_sample_data.information_schema.query_history()) "
            + f"where query_id = '{self.queryId}'")
        if len(rows) > 0:
            self.msg += "The query was found by ID in INFORMATION_SCHEMA.\n"
            return rows[0]
        else:
            self.msg += "Query not found (by ID) in INFORMATION_SCHEMA. Try the History tab in the Web UI.\n"
            return None

    def getAnalysis(self):
        self.msg = ""

        # collect all row metrics values for this query
        row = self._inAccountUsageById()
        self.isAccountUsage = row is not None
        if not self.isAccountUsage:
            row = self._inInformationSchemaById()
        self.props = row.as_dict()
        self.queryText = self.props['QUERY_TEXT'].replace("'", "''")

        # fill-in some properties from the explain plan
        queryText = self.props['QUERY_TEXT']
        explain = QueryAnalyzer.getExplain(queryText)
        explain_lines = explain.splitlines()
        self.props["PARTITIONS_TOTAL"] = int(explain_lines[1].split("=")[1].strip())
        self.props["PARTITIONS_SCANNED"] = int(explain_lines[2].split("=")[1].strip())
        self.props["BYTES_SCANNED"] = int(explain_lines[3].split("=")[1].strip())

        self.showQueryHistory()
        return self.msg

    # get query profile info query
    # see https://docs.snowflake.com/en/sql-reference/functions/get_query_operator_stats
    def getQueryProfileQuery(self):
        return f"select * from table(get_query_operator_stats('{self.queryId}'))";

    # return query text of a query, by ID
    def getQueryText(self):
        query = f"""select query_text
            from table(snowflake_sample_data.information_schema.query_history())
            where query_id = '{self.queryId}'"""
        rows = utils.runQuery(query)
        if rows is not None and len(rows) > 0:
            return str(rows[0][0])

        query = f"""select query_text
            from snowflake.account_usage.query_history
            where query_id = '{self.queryId}'"""
        rows = utils.runQuery(query)
        if rows is not None and len(rows) > 0:
            return str(rows[0][0])

        return None

    @classmethod
    def getExplain(cls, queryText):
        query = f"explain using text\n\t{queryText}"
        rows = utils.runQuery(query)
        return str(rows[0][0])

    # return query ID and text of the last run query
    @classmethod
    def getLastQuery(cls):
        query = """select top 1 query_id, query_text
            from table(snowflake_sample_data.information_schema.query_history())
            order by start_time desc"""
        rows = utils.runQuery(query)
        if rows is not None and len(rows) > 0:
            return str(rows[0][0]), str(rows[0][1])
        return None, None
