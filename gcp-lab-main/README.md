<h1>Home assignment. GCP module.</h1>

<h3>Creation of standart envs., compute engine, templates, mig, lb, web software, storage, bigquery, logging, sheduler, pub/sub, cloud functions.</h3>

<h3>Task should be done via GCP Shell (gcloud, gsutil commands) and GCP Console (WEB GUI).</h3>

<h4>Task 1:</h4>

1. Create bucket for application files and another one for static web files (think about permissions)
2. Create MIG for backend with installed tomcat and on boot download demo application from bucket
3. Setup autoscaling buy CPU (think about scale down)
4. Create LB
5. Add one more MIG for frontend with nginx, by path /demo/ show demo app from bucket, by path /img/picture.jpg show file from bucket
6. Setup export of nginx logs to bucket/BigQuery

<h4>Task 2:</h4>

1. Replace the agent for exporting logs (if there was a Google one, it will switch to an older solution and vice versa)
2. Replace the base operating system in the backend group (ubuntu <-> centos)
3. Configure the internal LB so that it transfers traffic only if the target host tomcat returns http status 20x
4. Figure out how prohibit killing of a specific node (on which a long process is currently spinning)
5. Check info about pub/sub and events

<h4>Task 3:</h4>
1. Create a function (python3) that will run through pubsub and print a message
2. Configure automatic start of this function every hour
3. (optional) The function should connect to BigQuery and display statistics on http responses for the last hour
4. Create one more function that will run every time nginx issues a 404 error and display the error text
