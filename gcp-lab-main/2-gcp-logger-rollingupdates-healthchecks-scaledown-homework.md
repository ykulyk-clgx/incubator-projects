# GCP assignment, part 2
## 1. Use different agent for exporting logs on nginx MIG:
Implemented the task with Elastic software: FileBeat + Logstash.
Firstly, created a service account with write access to the mk-private2 bucket:
```
gcloud iam service-accounts create nginx-logs --display-name="nginx-logs"
```
```
gsutil iam ch nginx-logs@hip-apricot-592.iam.gserviceaccount.com:objectCreator gs://mk-private2
```
Generated a key (service account) and downloaded it:
```
gcloud iam service-accounts keys create hip-apricot-592-89ee152fd9ab --iam-account=nginx-logs@hip-apricot-592.iam.gserviceaccount.com.iam.gserviceaccount.com
```
Tested everything on temp vm, from there downloaded file /etc/filebeat/filebeat.yml (available on the bucket). Difference from the original config and new config file is 2 lines at the end:
```
output.logstash:
  hosts: ["localhost:5044"]
```
Edited config /etc/logstash/logstash-sample.conf (available on the bucket):
```
input {
  beats {
    port => 5044
  }
}

output {
  google_cloud_storage {
    bucket => "mk-private2"
    json_key_file => "/etc/logstash/hip-apricot-592-89ee152fd9ab.json"
  }

#  elasticsearch {
#    hosts => ["http://localhost:9200"]
#    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
#    #user => "elastic"
#    #password => "changeme"
#  }
}
```
After dozens of experiments created a working startup script for a debian vm (implemented in template lower):
```
sudo apt install apt-transport-https default-jre
curl -o https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update && sudo apt install filebeat logstash -y
sudo systemctl enable filebeat
stash modules enable system nginx
sudo /usr/share/logstash/bin/logstash-plugin install logstash-output-google_cloud_storage
sudo gsutil cp gs://mk-private2/default /etc/nginx/sites-enabled/default
sudo gsutil cp gs://mk-private2/filebeat.yml /etc/filebeat/filebeat.yml
sudo gsutil cp gs://mk-private2/logstash-sample.conf /etc/logstash/logstash-sample.conf
sudo filebeat -e -c /etc/filebeat/filebeat.yml -d "publish" &
sudo /usr/share/logstash/bin/logstash -f /etc/logstash/logstash-sample.conf --config.reload.automatic &
```
Created a new template, with a startup script --^:
```
gcloud beta compute --project=hip-apricot-592 instance-templates create nginx-instance-template --machine-type=e2-micro --network=projects/hip-apricot-592/global/networks/default --network-tier=PREMIUM --metadata=startup-script=sudo\ apt\ install\ apt-transport-https\ default-jre$'\n'curl\ -o\ https://artifacts.elastic.co/GPG-KEY-elasticsearch\ \|\ sudo\ apt-key\ add\ -$'\n'echo\ \"deb\ https://artifacts.elastic.co/packages/7.x/apt\ stable\ main\"\ \|\ sudo\ tee\ -a\ /etc/apt/sources.list.d/elastic-7.x.list$'\n'sudo\ apt\ update\ \&\&\ sudo\ apt\ install\ filebeat\ logstash\ -y$'\n'sudo\ systemctl\ enable\ filebeat$'\n'stash\ modules\ enable\ system\ nginx$'\n'sudo\ /usr/share/logstash/bin/logstash-plugin\ install\ logstash-output-google_cloud_storage$'\n'sudo\ gsutil\ cp\ gs://mk-private2/default\ /etc/nginx/sites-enabled/default$'\n'sudo\ gsutil\ cp\ gs://mk-private2/filebeat.yml\ /etc/filebeat/filebeat.yml$'\n'sudo\ gsutil\ cp\ gs://mk-private2/logstash-sample.conf\ /etc/logstash/logstash-sample.conf$'\n'sudo\ filebeat\ -e\ -c\ /etc/filebeat/filebeat.yml\ -d\ \"publish\"\ \&$'\n'sudo\ /usr/share/logstash/bin/logstash\ -f\ /etc/logstash/logstash-sample.conf\ --config.reload.automatic\ \& --maintenance-policy=MIGRATE --service-account=nginx-logs@hip-apricot-592.iam.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server --image=debian-10-buster-v20210721 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-balanced --boot-disk-device-name=nginx-instance-template --no-shielded-secure-boot --no-shielded-vtpm --no-shielded-integrity-monitoring --reservation-affinity=any
```
Updated my nginx MIG:
```
gcloud beta compute instance-groups managed rolling-action start-update nginx-instance-group --project=hip-apricot-592 --type='proactive' --max-surge=1 --max-unavailable=1 --min-ready=0 --minimal-action='replace' --most-disruptive-allowed-action='replace' --replacement-method='substitute' --version=template=projects/hip-apricot-592/global/instanceTemplates/nginx-instance-template --zone=europe-central2-a
```
After some minutes got a log (firstly tried with export on public bucket, then on private + service account key):

![image](https://user-images.githubusercontent.com/72446184/128642391-91334a65-6c96-40da-bf1b-6d690e6c6d74.png)
![image](https://user-images.githubusercontent.com/72446184/128642394-2fb7c1f8-a9d3-4e53-a9a3-cbb75db7f08f.png)
![image](https://user-images.githubusercontent.com/72446184/128642400-560331f4-716f-4bde-ba8c-b256221b9cd8.png)
![image](https://user-images.githubusercontent.com/72446184/128642405-9cae6175-d739-4cdb-ab9e-4bcbf1b0607d.png)
 
## 2. Change OS type for a tomcat MIG:
Created a new bucket, for new experiments (used also in task 1):
```
gsutil mb -c standard -l europe-central2 gs://mk-private2
```
Set access for the service account (account was used previously, in the first hm):
```
gsutil iam ch serviceAccount:1077493884879@developer.gserviceaccount.com:objectAdmin gs://mk-private2
```
Uploaded all config files and app, list:

![image](https://user-images.githubusercontent.com/72446184/128642409-55ef622e-8d8c-48f6-98e3-076b63d6b4a1.png)

Used MIG that was created at previous hm assignment.
Instance template:
```
gcloud beta compute --project=hip-apricot-592 instance-templates create tomcat-instance-template-9-0-52 --machine-type=e2-micro --network=projects/hip-apricot-592/global/networks/default --network-tier=PREMIUM --metadata=startup-script=sudo\ apt\ update$'\n'sudo\ apt\ install\ default-jdk\ curl\ -y$'\n'sudo\ update-java-alternatives\ -l$'\n'sudo\ groupadd\ tomcat$'\n'sudo\ useradd\ -s\ /bin/false\ -g\ tomcat\ -d\ /opt/tomcat\ tomcat$'\n'sudo\ mkdir\ /opt/tomcat$'\n'curl\ -O\ https://downloads.apache.org/tomcat/tomcat-9/v9.0.52/bin/apache-tomcat-9.0.52.tar.gz$'\n'sudo\ tar\ xf\ apache-tomcat-9\*tar.gz\ -C\ /opt/tomcat\ --strip-components=1$'\n'sudo\ chgrp\ -R\ tomcat\ /opt/tomcat$'\n'sudo\ chmod\ -R\ g\+r\ /opt/tomcat/conf$'\n'sudo\ chmod\ g\+x\ /opt/tomcat/conf$'\n'sudo\ chown\ -R\ tomcat\ /opt/tomcat/webapps/\ /opt/tomcat/work/\ /opt/tomcat/temp/\ /opt/tomcat/logs/$'\n'sudo\ gsutil\ cp\ gs://mk-private2/tomcat.service\ /etc/systemd/system/tomcat.service$'\n'sudo\ gsutil\ cp\ gs://mk-private2/tomcat-users.xml\ /opt/tomcat/conf/tomcat-users.xml$'\n'sudo\ gsutil\ cp\ gs://mk-private2/sample.war\ /opt/tomcat/webapps/sample.war$'\n'sudo\ systemctl\ start\ tomcat$'\n'sudo\ systemctl\ enable\ tomcat --maintenance-policy=MIGRATE --service-account=1077493884879@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --image=debian-10-buster-v20210721 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-balanced --boot-disk-device-name=tomcat-instance-template-9-0-52 --no-shielded-secure-boot --no-shielded-vtpm --no-shielded-integrity-monitoring --reservation-affinity=any
```
Health check:
```
gcloud compute --project "hip-apricot-592" health-checks create http "tomcat-heathcheck" --timeout "5" --check-interval "30" --unhealthy-threshold "3" --healthy-threshold "2" --port "8080" --request-path "/sample"
```
MIG:
```
gcloud beta compute --project=hip-apricot-592 instance-groups managed create tomcat-instance-group --base-instance-name=tomcat-instance-group --template=tomcat-instance-template-9-0-52 --size=1 --zone=europe-central2-a --health-check=tomcat-heathcheck --initial-delay=300
```
Autoscaling policy:
```
gcloud beta compute --project "hip-apricot-592" instance-groups managed set-autoscaling "tomcat-instance-group" --zone "europe-central2-a" --cool-down-period "300" --max-num-replicas "2" --min-num-replicas "1" --target-cpu-utilization "0.7" --mode "on"
```
Created an temp centos instance and tested fidderent commands to make a working startup script.
OLD debian startup script (used in previous hm):
```
sudo apt update
sudo apt install default-jdk curl -y
sudo update-java-alternatives -l
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
sudo mkdir /opt/tomcat
curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.52/bin/apache-tomcat-9.0.52.tar.gz
sudo tar xf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r /opt/tomcat/conf
sudo chmod g+x /opt/tomcat/conf
sudo chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
sudo gsutil cp gs://mk-private2/tomcat.service /etc/systemd/system/tomcat.service
sudo gsutil cp gs://mk-private2/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
sudo gsutil cp gs://mk-private2/sample.war /opt/tomcat/webapps/sample.war
sudo systemctl start tomcat
sudo systemctl enable tomcat
```
New centos startup script:
```
sudo yum install java-1.8.0-openjdk-devel curl -y
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.52/bin/apache-tomcat-9.0.52.tar.gz
sudo tar xf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r /opt/tomcat/conf
sudo chmod g+x /opt/tomcat/conf
sudo chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
sudo sh -c 'chmod +x /opt/tomcat/bin/*.sh'
sudo gsutil cp gs://mk-private2/centos-tomcat.service /etc/systemd/system/tomcat.service
sudo gsutil cp gs://mk-private2/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
sudo gsutil cp gs://mk-private2/sample.war /opt/tomcat/webapps/sample.war
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
```
Implemented startup script in tomcat template:
```
gcloud beta compute --project=hip-apricot-592 instance-templates create tomcat-instance-template-9-0-52-centos --machine-type=e2-micro --network=projects/hip-apricot-592/global/networks/default --network-tier=PREMIUM --metadata=startup-script=sudo\ yum\ install\ java-1.8.0-openjdk-devel\ curl\ -y$'\n'sudo\ groupadd\ tomcat$'\n'sudo\ useradd\ -s\ /bin/false\ -g\ tomcat\ -d\ /opt/tomcat\ tomcat$'\n'curl\ -O\ https://downloads.apache.org/tomcat/tomcat-9/v9.0.52/bin/apache-tomcat-9.0.52.tar.gz$'\n'sudo\ tar\ xf\ apache-tomcat-9\*tar.gz\ -C\ /opt/tomcat\ --strip-components=1$'\n'sudo\ chgrp\ -R\ tomcat\ /opt/tomcat$'\n'sudo\ chmod\ -R\ g\+r\ /opt/tomcat/conf$'\n'sudo\ chmod\ g\+x\ /opt/tomcat/conf$'\n'sudo\ chown\ -R\ tomcat\ /opt/tomcat/webapps/\ /opt/tomcat/work/\ /opt/tomcat/temp/\ /opt/tomcat/logs/$'\n'sudo\ sh\ -c\ \'chmod\ \+x\ /opt/tomcat/bin/\*.sh\'$'\n'sudo\ gsutil\ cp\ gs://mk-private2/centos-tomcat.service\ /etc/systemd/system/tomcat.service$'\n'sudo\ gsutil\ cp\ gs://mk-private2/tomcat-users.xml\ /opt/tomcat/conf/tomcat-users.xml$'\n'sudo\ gsutil\ cp\ gs://mk-private2/sample.war\ /opt/tomcat/webapps/sample.war$'\n'sudo\ systemctl\ daemon-reload$'\n'sudo\ systemctl\ start\ tomcat$'\n'sudo\ systemctl\ enable\ tomcat --maintenance-policy=MIGRATE --service-account=1077493884879@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --image=centos-7-v20210721 --image-project=centos-cloud --boot-disk-size=20GB --boot-disk-type=pd-balanced --boot-disk-device-name=tomcat-instance-template-9-0-53-centos --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
```
Applied rolling update on MIG, debian > centos:
```
gcloud beta compute instance-groups managed rolling-action start-update tomcat-instance-group --project=hip-apricot-592 --type='proactive' --max-surge=1 --max-unavailable=1 --min-ready=0 --minimal-action='replace' --most-disruptive-allowed-action='replace' --replacement-method='substitute' --version=template=projects/hip-apricot-592/global/instanceTemplates/tomcat-instance-template-9-0-52-centos --zone=europe-central2-a
```
After some minutes got a working page:

![image](https://user-images.githubusercontent.com/72446184/128642425-e0808ad2-36c2-4f6d-b7b9-6bf9c2c5c7be.png)

![image](https://user-images.githubusercontent.com/72446184/128642431-8a59f7b6-48cd-4a00-ada9-7abd7a5a90b7.png)


## 3. LB should redirect only to vms that show 20x HTTP code:
Lets see an example of such LB.  
Fistly, we should configure heath check for our LB backend:
```
gcloud beta compute health-checks create http hc-http-tomcat-8080 --project=hip-apricot-592 --port=8080 --request-path=/sample --proxy-header=NONE --no-enable-logging --check-interval=30 --timeout=10 --unhealthy-threshold=2 --healthy-threshold=2
```
Add backend service:
```
gcloud compute backend-service create tomcat-internal-ln --load-balancing-scheme=internal-managed --protocol =http --region=europe-cental2 --health-checks=hc-http-tomcat-8080 --health-check-region=europe-cental2
```
```
gcloud compute backend-services add-backend tomcat-internal-ln --region=europe-cental2 --instance-group=tomcat-instance-group --instance-group-zone=europe-cental2
```
Configure internal DNS, optional:
```
gcloud beta dns --project=hip-apricot-592 managed-zones create backend-dns --description="DNS for backends" --dns-name="internal.hosts." --visibility="private" --networks="default"
```
```
gcloud dns --project=hip-apricot-592 record-sets transaction start --zone=backend-dns
```
```
gcloud dns --project=hip-apricot-592 record-sets transaction add 10.186.0.4 --name=backend-tomcat.internal.hosts. --ttl=300 --type=A --zone=backend-dns
```
```
gcloud dns --project=hip-apricot-592 record-sets transaction execute --zone=backend-dns
```
Set frontend:
```
gcloud compute forwarding-rules create tomcat-internal-lb --region europe-central2 --load-balancing-scheme=internal --network=default --subnet=default --address=backend-tomcat.internal.hosts --ip-protocol=TCP --ports=80,8080 --backend-service=tomcat-internal-ln --backend-service-region=europe-cental2
```

## 4. Stop deletion of scaled (down) instances in MIG
The plan: 
- Set target-cpu-utilization option to "0.2" and cool-down-period to "10" (autoscaling policy in MIG), so on boot (of any machine) scale policy will detect “overload” and add one more instance, after ~3-5 mins load on all machines shall be stabilized (at ~5%) - triggering scale down. 
- While machines in MIG will be up - send delete-protection command, so chosen machine will not be killed by a scheduler.

Reality: 
- Looks like deletion protection policy does not work with instances that are started by MIG, needed to find another way.

Tried shell command + GUI (gcp console did not allow me to enable deletion protection):
```
gcloud compute instances update tomcat-instance-group-00tr --deletion-protection
```
Got an error:

`ERROR: (gcloud.compute.instances.update) HTTPError 400: Invalid resource usage: 'Cannot set Deletion Protection on instance attached to Managed Instance Group.'.`
