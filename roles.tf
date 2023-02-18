################################################################################
# Roles
################################################################################

#Manage AWS SSM policy
data "aws_iam_policy" "ssm_manage_instance_core_policy" {  # Import AWS Manage policy mainly for AWS session Manager.
  name = "AmazonSSMManagedInstanceCore"
}

# Web instance role & policy
resource "aws_iam_instance_profile" "web" {             # Create instance profile
  name = "allow_ec2_ssm_profile"
  role = aws_iam_role.web_role.name
}

resource "aws_iam_role" "web_role" {                    # Create web tier ec2 roles
  name = "allow_ec2_ssm"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_manage_instance_core_web_policy" {
  role       = aws_iam_role.web_role.name
  policy_arn = data.aws_iam_policy.ssm_manage_instance_core_policy.arn
}

# App instance role & policy
resource "aws_iam_instance_profile" "app" {             # Create instance profile
  name = "allow_ec2_access_aws_services_profile"
  role = aws_iam_role.app_role.name
}

resource "aws_iam_role" "app_role" {                    # Create app tier ec2 roles
  name = "allow_ec2_access_aws_services_roles"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# App instance policy
resource "aws_iam_role_policy" "app_policy" {               # Create app tier ec2 policy
  name = "allow_ec2_access_aws_services_roles_policy"
  role = aws_iam_role.app_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:*",
        "cloudwatch:*",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_manage_instance_core_app_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = data.aws_iam_policy.ssm_manage_instance_core_policy.arn
}