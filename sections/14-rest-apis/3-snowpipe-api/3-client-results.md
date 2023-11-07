**``> python 4-snowpipe-api-client.py'**

**Ingest Report** (when not completed):
```
{
   "pipe": "EMPLOYEES.PUBLIC.MYPIPE",
   "completeResult": true,
   "nextBeginMark": "1_-1",
   "files": [],
   "statistics": { "activeFilesCount": 2 }
}
```

**Ingest Report** (when completed):
```
{
   "pipe": "EMPLOYEES.PUBLIC.MYPIPE",
   "completeResult": true,
   "nextBeginMark": "1_1",
   "files": [{
         "path": "emp12.csv",
         "stageLocation": "stages/11bd5b4d-8e0f-4bfe-bec6-bb8694f358ce/",
         "fileSize": 400,
         "timeReceived": "2023-11-06T17:30:31.843Z",
         "lastInsertTime": "2023-11-06T17:30:48.777Z",
         "rowsInserted": 9,
         "rowsParsed": 9,
         "errorsSeen": 0,
         "errorLimit": 1,
         "complete": true,
         "status": "LOADED"
      },{
         "path": "emp11.csv",
         "stageLocation": "stages/11bd5b4d-8e0f-4bfe-bec6-bb8694f358ce/",
         "fileSize": 240,
         "timeReceived": "2023-11-06T17:30:31.843Z",
         "lastInsertTime": "2023-11-06T17:30:48.777Z",
         "rowsInserted": 5,
         "rowsParsed": 5,
         "errorsSeen": 0,
         "errorLimit": 1,
         "complete": true,
         "status": "LOADED"
      }],
   "statistics": { "activeFilesCount": 0 }
}
```

**History scan report** (for the past hour):
```
{
   "files": [{
         "path": "emp11.csv",
         "stageLocation": "stages/11bd5b4d-8e0f-4bfe-bec6-bb8694f358ce/",
         "fileSize": 240,
         "timeReceived": "2023-11-06T17:30:31.843Z",
         "lastInsertTime": "2023-11-06T17:30:48.569Z",
         "rowsInserted": 5,
         "rowsParsed": 5,
         "errorsSeen": 0,
         "errorLimit": 1,
         "complete": true,
         "status": "LOADED"
      },{
         "path": "emp12.csv",
         "stageLocation": "stages/11bd5b4d-8e0f-4bfe-bec6-bb8694f358ce/",
         "fileSize": 400,
         "timeReceived": "2023-11-06T17:30:31.843Z",
         "lastInsertTime": "2023-11-06T17:30:48.569Z",
         "rowsInserted": 9,
         "rowsParsed": 9,
         "errorsSeen": 0,
         "errorLimit": 1,
         "complete": true,
         "status": "LOADED"
      }],
   "startTimeInclusive": "2023-11-06T16:30:54.816Z",
   "endTimeExclusive": "2023-11-06T17:30:52.981Z",
   "rangeStartTime": "2023-11-06T17:30:48.569Z",
   "rangeEndTime": "2023-11-06T17:30:48.569Z",
   "pipe": "EMPLOYEES.PUBLIC.MYPIPE",
   "completeResult": "true"
}
```