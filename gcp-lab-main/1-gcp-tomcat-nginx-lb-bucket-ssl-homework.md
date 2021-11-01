# GCP assignment, part 1:
1. Created 2 buckets (public and private). Uploaded tomcat app and nginx config file on mk-private and cats pics on mk-notprivate (mk-public name was already taken):
 
![image](https://user-images.githubusercontent.com/72446184/128642491-6513db69-2f3a-4f0e-8260-1c0dd19edcfb.png)

![image](https://user-images.githubusercontent.com/72446184/128642494-c09cabe6-3458-4ecb-a952-d330992891f9.png)

![image](https://user-images.githubusercontent.com/72446184/128642497-d6adfb92-c330-4e63-b1a6-9c745585edda.png)

![image](https://user-images.githubusercontent.com/72446184/128642499-88d7d826-9cd4-48f1-a0e2-22dc529b15fc.png)

Set all users access on the public bucket:
 
![image](https://user-images.githubusercontent.com/72446184/128642503-8d8949e9-8800-4fc4-a72d-80d3b2a00817.png)

Created service account to access bucket from vms:
 
![image](https://user-images.githubusercontent.com/72446184/128642507-cdf41039-b6df-4513-af1a-b68bbdbb3bd2.png)

Set service account access:
 
![image](https://user-images.githubusercontent.com/72446184/128642511-b168f7b3-58d9-487a-8010-2db60c04042b.png)
	
Created an instance + firewall rule, for tomcat install, some tests + demo app:
 
![image](https://user-images.githubusercontent.com/72446184/128642517-47c2de09-348b-4092-beb9-93bfc2f3e8d4.png)

![image](https://user-images.githubusercontent.com/72446184/128642523-15eb2578-d771-4b0b-a911-b12e49dc4234.png)

Hosted simple application, file imported from the private bucket (sample2.war):

![image](https://user-images.githubusercontent.com/72446184/128642527-41629300-c334-4ada-9f70-b7e27fb170e6.png)

Created an image from my vm (debian 10 + fully configured tomcat server):

![image](https://user-images.githubusercontent.com/72446184/128642538-e376a3c6-c9db-40aa-817b-337a829a5563.png)


2-3. Created a template for a new MIG:
 
![image](https://user-images.githubusercontent.com/72446184/128642543-639608c8-78d3-4b81-bc90-b6163815bb5a.png)

Configured a MIG + autoscaling:

![image](https://user-images.githubusercontent.com/72446184/128642554-f7d2bb9e-1db8-4aba-92f4-40ffebf3085a.png)

4. Created a health check, needed for internal LB:

![image](https://user-images.githubusercontent.com/72446184/128642559-3988be20-9aa2-4f79-b0d1-fd9e63067e13.png)

Added LB backend, health service, route to tomcat MIG:
 
![image](https://user-images.githubusercontent.com/72446184/128642567-490af234-ff60-46b6-9a0b-63bef4eabbbd.png)

![image](https://user-images.githubusercontent.com/72446184/128642571-aac650b6-dded-4fc7-85e1-eb3614d7cbc4.png)
	
Added front to back LB route:

![image](https://user-images.githubusercontent.com/72446184/128642578-9225dfec-334a-415f-915a-cf794ca2d229.png)

5. Added MIG for the web (nginx) instances (template + health check + auto-scaling rules):
 
![image](https://user-images.githubusercontent.com/72446184/128642581-9cc5a27f-7658-49e3-843d-d60b27cceba4.png)

![image](https://user-images.githubusercontent.com/72446184/128642583-4d8c4583-a3c0-4d84-8bad-71dd0f85ef34.png)

![image](https://user-images.githubusercontent.com/72446184/128642591-62034149-baa6-403e-9f11-26649861b5a4.png)

![image](https://user-images.githubusercontent.com/72446184/128642601-ee5bbdd1-fd71-4d1a-9ef0-355c12c78ad0.png)

Auto start script, used in nginx template (nginx install + config file import + gcp logger install):

![image](https://user-images.githubusercontent.com/72446184/128642607-a9fc07c9-a58d-4cfe-b158-b0508f578497.png)

Edited default nginx config, added rewrite (used for page redirection at /img/name.jpg) and proxy (/demo/sample2). 
Tomcat sample app is accessible from nginx servers (front -> back) + nginx pages (/img/ path) can redirect to images on public bucket:

![image](https://user-images.githubusercontent.com/72446184/128642623-a660a4f7-ea3a-4be2-94a6-4a19fef324c9.png)

Created an external HTTP/s LB, accessed app on LB IP:
 
![image](https://user-images.githubusercontent.com/72446184/128642630-70f2c3a7-0ebc-419e-9a66-3cbd23ab90ae.png)

![image](https://user-images.githubusercontent.com/72446184/128642634-28648ffb-1a22-4c38-8f91-ca3fe19898e2.png)


Typed a /img/name.png path, get an image from the mk-notpublic bucket:	

![image](https://user-images.githubusercontent.com/72446184/128642639-3e0fd45d-8da7-40fc-8215-baa16d9b8656.png)


6. Created BigQuery dataset, all nginx logs will be stored there:

![image](https://user-images.githubusercontent.com/72446184/128642641-2158bf20-4a47-49be-b08c-fd83731a2cdd.png)

Created a sink (logger -> BigQuery):

![image](https://user-images.githubusercontent.com/72446184/128642648-558c108a-fc7b-4a05-8a66-ce518f3b8bc6.png)

Get logs with a simple sql request:

![image](https://user-images.githubusercontent.com/72446184/128642650-3a01ec66-78dc-4f81-b1d6-7a722311e01d.png)

7. SSL discovery and usage in GCP
HTTPS can be implemented with external LB – select HTTPS, select or create google-managed certificate, buy or choose domain. Or we can user own ssl certificate (letsencrypt + certbot …) and domain (godaddy, etc), which can imported in gcp.

Tried to make own experiments, implemented ssl on my test nextloud vm (configured new network + firewall rules). Enabled permanent ip, bought a domain at hostinger (godaddy was cheaper but requested a credit card, on hostinger used gpay (domain costs me ~1 dollar, same domain in gcp starts from 12 per year)), entered A + CNAME (for www.) records. Configured host nextcloud on port 80 – apache config, installed certbot (+ started a config script), changed some settings in ssl config (apache). After a few minutes had own encrypted connection.

![image](https://user-images.githubusercontent.com/72446184/128642661-6f1ee9dc-be2c-4b5e-8075-aa3f183f9fd9.png)

![image](https://user-images.githubusercontent.com/72446184/128642666-e5e02213-4e20-44cd-bc87-d953efbab712.png)


![image](https://user-images.githubusercontent.com/72446184/128642664-9b2d8290-9fef-4d67-ab64-2d6bfe5684c6.png)
