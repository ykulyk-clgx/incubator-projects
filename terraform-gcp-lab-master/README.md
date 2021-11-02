<h1>Terraform assignment, GCP inf</h1>

![image](https://user-images.githubusercontent.com/90634203/139848262-b15dad42-ed98-4c34-9626-d43798a8e4ee.png)

<h3>Deploy infrastructure, described on the diagram above:</h3>

1. Create Network and private subnetwork. 

2. Create 2 instances with LAMP stack. Instances should be in the private subnet and do not have public IP addresses. 

3. You should be able to SSH to the instances with tag `ssh` only from your IP address. 

4. Instance should be able to pull config from Cloud Storage. 

5. LAMP stack should be installed on the instances during instance provisioning. 

6. Instances should have access to the Internet. 

7. Database should be in Cloud SQL service. 

8. Password for database should be located inside secret manager. 

9. HTMP page (index.html) should be located inside Cloud Storage bucket. 

10. LAMP stack should be accessible over the internet using load balancer AND only from your IP address. 

11. Backups for cloud SQL database should be configured. 

<h3>General rules:</h3>

1. Your code should be in EPAM GitLab repository and accessible for reviewers. 

2. You should create your infrastructure using one terraform command. Manual changes are not allowed. 

3. Terraform backend state should be in GCS. 

4. Needed attributes for your terraform code should be parametrized (Example: Customer may want to increase or decrease instance type if needed in some period of time). 

5. Use Terraform linters to meet all terraform best practices in code writing. 

6. Use Terraform modules as much as possible (when it is needed). 

 
