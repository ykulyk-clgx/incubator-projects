#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo gsutil cp gs://xamp-site-bucket-xmpl/index.html /var/www/html/index.html
sudo yum install mariadb-server mariadb  -y
sudo systemctl start mariadb
sudo systemctl enable mariadb.service
sudo mysql -e \"DROP USER ''@'localhost'\"
sudo mysql -e \"DROP USER ''@'$(hostname)'\"
sudo mysql -e \"DROP DATABASE test\"
sudo mysql -e \"FLUSH PRIVILEGES\"
sudo yum install php php-mysql  -y
sudo systemctl restart httpd.service
