#Main
name="3-tier"
region="ap-southeast-1"
tags={
    Terraform = "true",
    Environment = "dev"
    }

#VPC
cidr="10.4.0.0/24"
public_subnets=["10.4.0.32/27","10.4.0.64/27"]
private_subnets=["10.4.0.128/27","10.4.0.160/27"]
database_subnets=["10.4.0.192/27","10.4.0.224/27"]
azs=["ap-southeast-1a","ap-southeast-1b"]

#EC2
web_instance_type="t2.micro"
app_instance_type="t2.micro"
web_storage="8"
app_storage="8"

#RDS
db_storage="10"
db_engine="mysql"
db_version="8.0.32"
db_instance_type="db.t3.micro"
db_multi_az=false
db_username="admin"
db_password="12345qwert"

#Route53
hosted_domain="solution.com"
app_domain="app.solution.com"
db_domain="db.solution.com"
