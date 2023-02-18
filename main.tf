################################################################################
# VPC
################################################################################

 # VPC
 resource "aws_vpc" "main" {                
   cidr_block                       = var.cidr          # Defining the CIDR block use 10.4.0.0/24 for assignment
   instance_tenancy                 = var.instance_tenancy      # Default value is "default"
   enable_dns_hostnames             = var.enable_dns_hostnames  # Default value is true
   enable_dns_support               = var.enable_dns_support    # Default value is true
   assign_generated_ipv6_cidr_block = var.enable_ipv6    # Default value is false

   tags = merge(                            
    {"Name" = format("%s", var.name)},
    var.tags,
    var.vpc_tags,
)                                       # Resources tag
 }

 # IGW
 resource "aws_internet_gateway" "igw" {    
    vpc_id = aws_vpc.main.id    # Create Internet Gateway

    tags = merge(
        {"Name" = format("%s", var.name)},
        var.tags,
        var.igw_tags,
        )
 }

# Public Subnets.
 resource "aws_subnet" "public_subnets" {    # Creating Public Subnets
    count                   = length(var.public_subnets) # Check how may subnet
    vpc_id                  = aws_vpc.main.id      
    cidr_block              = element(var.public_subnets, count.index) # CIDR block of public subnets
    availability_zone       = element(var.azs, count.index)     # Map each public and private subnet across avaibility zones.
    map_public_ip_on_launch = var.map_public_ip_on_launch       # Default is false


    tags = merge(
    {"Name" = format("public-subnet-%s-${count.index + 1}", var.name)},
    var.tags,
    var.subnet_tags,
)
 }

 # Private Subnet                   
 resource "aws_subnet" "private_subnets" {    # Creating Private Subnets
    count             = length(var.private_subnets) # Check how may subnet
    vpc_id            = aws_vpc.main.id      
    cidr_block        = element(var.private_subnets, count.index) # CIDR block of public subnets
    availability_zone = element(var.azs, count.index)     # Map each public and private subnet across avaibility zones.


    tags  = merge(
    {
    "Name" = format("private-subnet-%s-${count.index + 1}", var.name)},
    var.tags,
    var.subnet_tags,
  )
 }

 # Database Subnet                   
 resource "aws_subnet" "database_subnets" {    # Creating Database Subnets
    count             = length(var.database_subnets) # Check how may subnet
    vpc_id            = aws_vpc.main.id      
    cidr_block        = element(var.database_subnets, count.index) # CIDR block of public subnets
    availability_zone = element(var.azs, count.index)     # Map each public and private subnet across avaibility zones.


    tags  = merge(
    {
    "Name" = format("database-subnet-%s-${count.index + 1}", var.name)},
    var.tags,
    var.subnet_tags,
  )
 }
 
 
 # RT Public Subnet's
 resource "aws_route_table" "public_rt" {    # Creating RT for Public Subnet
    vpc_id  =  aws_vpc.main.id
        route {
    cidr_block = "0.0.0.0/0"       # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.igw.id # IGW id define here
    }

    tags  = merge(
    {
    "Name" = format("public-subnet-rt-%s", var.name)},
    var.tags,
    var.rt_subnet_tags,
  )
}

 # RT Private Subnet's
 resource "aws_route_table" "private_rt" {    # Creating RT for Private Subnet
    count = length(aws_subnet.private_subnets)
    vpc_id = aws_vpc.main.id
        route {
    cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
    nat_gateway_id = aws_nat_gateway.nat[count.index].id # Every subnet will have one NAT gateway attached to RT
    }

    tags  = merge(
    {
    "Name" = format("private-subnet-rt-%s-${count.index + 1}", var.name)},
    var.tags,
    var.rt_subnet_tags,
  )
 }

#  Route table Association with Public Subnet's
 resource "aws_route_table_association" "public_rt_associate" {   # Create Public subnet route table association
    count = length(var.public_subnets)
    subnet_id      = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public_rt.id
 }

# Route table Association with Private Subnet's
 resource "aws_route_table_association" "private_rt_associate" {  # Create Private subnet route table association
    count = length(var.private_subnets)
    subnet_id      = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private_rt[count.index].id
 }

 # Route table Association with Database Subnet's
 resource "aws_route_table_association" "database_rt_associate" { # Create Database subnet route table association
    count = length(var.database_subnets)
    subnet_id      = aws_subnet.database_subnets[count.index].id
    route_table_id = aws_route_table.private_rt[count.index].id
 }


# NAT
resource "aws_eip" "eip" {                      # Creating Elastic ip for NAT Gateway
    count = length(aws_subnet.public_subnets)
    vpc   = true
    depends_on = [
      aws_internet_gateway.igw
    ]

    tags = merge(                            
    {"Name" = format("%s", var.name)},
    var.tags,
    var.eip_tags,
)
 }

resource "aws_nat_gateway" "nat" {              # Creating NAT gateway for each Avaibility Zones
  count = length(aws_subnet.public_subnets)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = merge(                            
    {"Name" = format("%s-${count.index + 1}", var.name)},
    var.tags,
    var.nat_tags,
)
}


################################################################################
# EC2
################################################################################

#Data Source
data "aws_ami" "amzn-linux" {  #Terraform reference data source from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
  most_recent = true
  owners = ["amazon"]

  filter {
        name   = "owner-alias"    # Reference from https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
        values = ["amazon"]
  }

  filter {
        name   = "name"
        values = ["amzn2-ami-kernel-*"]
  }

  filter {
        name   = "virtualization-type"
        values = ["hvm"]
  }
 
  filter {
        name   = "architecture"
        values = ["x86_64"]
  }

}

#Web tier launch template
resource "aws_launch_template" "web" { # Create launch template for web tier
  name = "web_server"

  block_device_mappings {
    device_name = "/dev/xvda"           # EBS volume

    ebs {
      volume_size = var.web_storage
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }

  instance_type = var.web_instance_type
  image_id      = data.aws_ami.amzn-linux.id

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web.id]
    delete_on_termination       = true
  }

  user_data = filebase64("${path.module}/script/web.sh")

  tags = merge(
    {"Name" = format("%s-web", var.name)},
     var.tags,
    )
}

#App tier launch template
resource "aws_launch_template" "app" { # Create launch template for app tier
  name = "app_server"

  block_device_mappings {
    device_name = "/dev/xvda"           # EBS volume

    ebs {
      volume_size = var.app_storage
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  instance_type = var.app_instance_type
  image_id      = data.aws_ami.amzn-linux.id

  network_interfaces {
    associate_public_ip_address = false
    # subnet_id                   = aws_subnet.private_subnets.*.id
    security_groups             = [aws_security_group.app.id]
    delete_on_termination       = true
  }

  user_data = filebase64("${path.module}/script/app.sh")

  tags = merge(
    {"Name" = format("%s-app", var.name)},
     var.tags,
    )
}

#ALB web tier
resource "aws_lb" "public" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_lb.id]
  subnets            = aws_subnet.public_subnets.*.id

  enable_deletion_protection = false
}

resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}

resource "aws_lb_target_group" "public" {
  name     = "web-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

#ALB app tier
resource "aws_lb" "private" {
  name               = "app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_lb.id]
  subnets            = aws_subnet.private_subnets.*.id

  enable_deletion_protection = false
}

resource "aws_lb_listener" "private" {
  load_balancer_arn = aws_lb.private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private.arn
  }
}

resource "aws_lb_target_group" "private" {
  name     = "app-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    matcher             = "200"
  }
}

################################################################################
# RDS
################################################################################

#Subnet Group
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db_subnet_group"
  subnet_ids = aws_subnet.database_subnets.*.id

  tags = merge(                            
    {"Name" = format("%s-db_subnet_group", var.name)},
    var.tags,
  )
}

resource "aws_db_instance" "rds" {
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
  allocated_storage      = var.db_storage
  engine                 = var.db_engine
  engine_version         = var.db_version
  instance_class         = var.db_instance_type
  multi_az               = var.db_multi_az
  db_name                = "soulutionDB"
  identifier             = "solutiondb"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
}