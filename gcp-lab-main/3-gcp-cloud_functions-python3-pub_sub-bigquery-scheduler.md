# GCP assignment, part 3
### 1. Create a cloud function (python3), use pub/sub to trigger it:

Created a pub/sub topic:
```
gcloud pubsub topics create cloud-function-python
```

And pub/sub subscription:
```
gcloud pubsub subscriptions create cloud-function-python cloud-function-python-sub
```

Created a folder and files in shell:
```
mkdir function-1
cd function-1
nano main.py
nano requirements.txt
```

Edited main.py file:
```
def pubsub(event, context):
    message = base64.b64decode(event['data']).decode('utf-8')
    
    print(message)
```

Deployed a function:
```
gcloud functions deploy function-1 --runtime=python39 --trigger-topic=cloud-function-python --entry-point=pubsub --memory=128mb --timeout=60s --max-instances=1 --region=europe-central2 
```

Tested with a message command:
```
gcloud pubsub topics publish cloud-function --message="test"
```

Got a result:

![image](https://user-images.githubusercontent.com/72446184/129588958-c333e321-4793-444b-879b-e72de5e39bc5.png)


### 2. Create a schedule to run cloud function every hour

In task 1 created cloud function and pub/sub. 
To make auto execution - used Cloud Scheduler.
Created a job with shell command:
```
gcloud scheduler jobs create pubsub python-function --schedule "0 */1 * * *" --topic cloud-function-python --message-body "Scheduled message - every hour"
```

And got:

![image](https://user-images.githubusercontent.com/72446184/129590010-d93723ec-07e8-4f7e-9156-51b43a462e40.png)

### 3. (optional) Cloud function should connect to bigquery - receive all http logs that were sent to the db table in last hour

Done in task 4 (main.py + bq + logs image).

### 4. Create a function that shows an error when nginx instance gets 404 error code

Configured an instance group with nginx and logger on board (detailed instructions in the last hws)

Opened /etc/nginx/nginx.conf file, added log file for 4xx errors. 
In the http section of the file added some lines:

```
map $status $loggable {
    ~^[4]   1;
    default 0;
}

access_log /var/log/nginx/404.log combined if=$loggable;
```

Opened google logger config file - /etc/google-fluentd/config.d/nginx.conf, added those lines:

```
<source>
  @type tail
  format none
  path /var/log/nginx/404.log
  pos_file /var/lib/google-fluentd/pos/nginx-404.pos
  read_from_head true
  tag nginx-404
</source>
```

Restarted nginx and logger applications with:
```
sudo service nginx restart
sudo service google-fluentd restart
```

Checked logs with:
```
gcloud logging read "resource.type=gce_instance logName=projects/hip-apricot-592/logs/nginx-404"
```
```
---
insertId: xgabnev0vbyita61e
labels:
  compute.googleapis.com/resource_name: nginx-instance
logName: projects/hip-apricot-592/logs/nginx-404
receiveTimestamp: '2021-08-16T14:12:52.379729762Z'
resource:
  labels:
    instance_id: '3275058625369336762'
    project_id: hip-apricot-592
    zone: europe-central2-a
  type: gce_instance
textPayload: - - [16/Aug/2021:14:12:46 +0000] "GET /sadasdasdasd HTTP/1.1"
  404 199 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML,
  like Gecko) Chrome/92.0.4515.131 Safari/537.36"
timestamp: '2021-08-16T14:12:46.307321164Z'
```

Created a pub/sub topic:
```
gcloud pubsub topics create	cloud-function-python
```

And pub/sub subscription:
```
gcloud pubsub subscriptions create cloud-function-python cloud-function-python-sub
```

Created a sink:
```
gcloud logging sinks create nginx_logs_sink pubsub.googleapis.com/projects/hip-apricot-592/topics/cloud-function-python --log-filter='resource.type=gce_instance logName=projects/hip-apricot-592/logs/nginx-404'
```

Requested new bigquery dataset:
```
bq --location=europe-central2 mk -d --description "python_export" python_export
```

Created new table in dataset:
```
bq mk -t 
  --description "function_logs" \
  python_export.function_logs \
  time:INTEGER,log:STRING
```

Checked some python examples, opened PyCharm, wrote the code:
```
import base64
import time
from google.cloud import bigquery


def make_query(mquery, mmessage):
    if mmessage:
        print(mmessage)

    client = bigquery.Client()
    query_job = client.query(mquery)
    rows = query_job.result()

    for row in rows:
        print(row)


def pubsub(event, context):
    message = base64.b64decode(event['data']).decode('utf-8')

    unix_time_ms = int(time.time() * 1000)
    unix_time_hour = 3600000  # 1 hour in ms
    unix_time_last_hour = str(unix_time_ms - unix_time_hour)

    print("Got an error:" + message)

    mquery = (
        'SELECT log FROM `hip-apricot-592.python_export.function_logs` '
        'WHERE time >= ' + unix_time_last_hour + ' '
        'LIMIT 100')

    make_query(mquery, "Printing all errors in 1 hour interval:")

    mquery = (
        'INSERT INTO `hip-apricot-592.python_export.function_logs` '
        'VALUES (' + str(unix_time_ms) + ', \'' + message + '\');')

    make_query(mquery, "Inserting new error in DB:")
```

Opened gcp shell, created a folder and files:
```
mkdir function-2
cd function-2
touch main.py
touch requirements.txt
```

Pasted the code in main.py file:
`
...
Code upper
...
`

Enterd required packet in requirements.txt file:
`
google-cloud-bigquery
`

Created a cloud function:
```
gcloud functions deploy function-2 --runtime=python39 --trigger-topic=cloud-function-python --entry-point=pubsub --memory=128mb --timeout=60s --max-instances=1 --region=europe-central2 
```

So, how that works:
![image](https://user-images.githubusercontent.com/72446184/129592466-66e2c1b5-ce61-4c99-b9ca-328713a1178f.png)

## A little presentation:
Opened a browser and entered unexisted page:
![image](https://user-images.githubusercontent.com/72446184/129597360-66e978f1-8c98-4548-87b0-7c8d25aa2f37.png)

Got the log:
![image](https://user-images.githubusercontent.com/72446184/129593544-962d1ba8-2688-4c27-9c02-d71773659194.png)

Checked BigQuery table:
![image](https://user-images.githubusercontent.com/72446184/129597880-b69004ab-ee92-4fbe-8d83-f0086e34523d.png)
