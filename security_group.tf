################################################################################
# Security Group
################################################################################

# Web EC2
resource "aws_security_group" "web" {               # Create security group for web instance
  name        = "allow_web_tier"
  description = "Allow HTTP from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_lb.id]    # Allow port 80 access from External ALB
  }

  # ingress {
  #   description     = "SSH"             # Allow SSH publicly for testing
  #   from_port       = 22
  #   to_port         = 22
  #   protocol        = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]        # Allow all access for outbound
  }

  tags = merge(
    {"Name" = format("web-%s-sg", var.name)},
     var.tags,
    )
}

#Web ALB
resource "aws_security_group" "web_lb" {                # Create security group for public ALB
  name        = "allow_web_public"
  description = "Allow HTTP from Internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]        # Allow access port 80 access to public 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]              # Allow all access for outbound
  }

  tags = merge(
    {"Name" = format("web-lb-%s-sg", var.name)},
     var.tags,
    )
}

#App EC2
resource "aws_security_group" "app" {               # Create security group for application instance
  name        = "allow_app_tier"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from internal alb"     # Allow port 8080 access from intenal ALB
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app_lb.id]
  }

  ingress {
    description     = "SSH from private subnet"     # Allow port 22 access from web instnace
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]            # Allow all outbound
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {"Name" = format("app-%s-sg", var.name)},
     var.tags,
    )
}

#App ALB
resource "aws_security_group" "app_lb" {            #Create security group for internal ALB
  name        = "allow_app_internal"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "HTTP from web instance"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]   # Allow port 80 to connect from web instance
  }

  # ingress {
  #   description     = "HTTP from web instance"
  #   from_port       = 8080
  #   to_port         = 8080
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.web.id]   # Allow port 8080 to connect from web instance
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]         # Allow all outbound
  }

  tags = merge(
    {"Name" = format("app-lb-%s-sg", var.name)},
     var.tags,
    )
}

#RDS
resource "aws_security_group" "rds" {            #Create security group for RDS
  name        = "allow_app_access_rds"
  description = "Allow MySQL"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "MySQL access from app"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]   # Allow port 3306 to connect from app instance
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]         # Allow all outbound
  }

  tags = merge(
    {"Name" = format("rds-%s-sg", var.name)},
     var.tags,
    )
}