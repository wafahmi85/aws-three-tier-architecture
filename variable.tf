variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "region" {
  description = "Region to deploy the resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to all resources"
  type        = map(string)
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden."
  type        = string
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC. Can be either default or dedicated."
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Determines whether the VPC supports assigning public DNS hostnames to instances with public IP addresses."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Determines whether the VPC supports DNS resolution through the Amazon provided DNS server."
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC."
  type        = bool
  default     = false
}

variable "vpc_tags" {
  description = "Tags for the VPC"
  type        = map(string)
  default     = {Resources = "vpc"}
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {Resources = "igw"}
}


variable "subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {Resources = "vpc_subnet"}
}

variable "rt_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {Resources = "vpc_route_table"}
}

variable "eip_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {Resources = "vpc_eip"}
}

variable "nat_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {Resources = "vpc_nat_gateway"}
}

variable "public_subnets" {
  description = "Public Subnet CIDR values"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private Subnet CIDR values"
  type        = list(string)
}

variable "database_subnets" {
  description = "Private Subnet CIDR values"
  type        = list(string)
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

variable "map_public_ip_on_launch" {
  description = "False if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = false
}

variable "web_instance_type" {
  description = "Region to deploy the resources"
  type        = string
}

variable "app_instance_type" {
  description = "Region to deploy the resources"
  type        = string
}

variable "web_storage" {
  description = "Region to deploy the resources"
  type        = string
}

variable "app_storage" {
  description = "Region to deploy the resources"
  type        = string
}

variable "db_storage" {
  description = "Region to deploy the resources"
  type        = string
}

variable "db_engine" {
  description = "Region to deploy the resources"
  type        = string
}

variable "db_version" {
  description = "Region to deploy the resources"
  type        = string
}

variable "db_instance_type" {
  description = "Region to deploy the resources"
  type        = string
}

variable "db_multi_az" {
  description = "Region to deploy the resources"
  type        = bool
}

variable "db_username" {
  description = "Region to deploy the resources"
  type        = string
}

variable "db_password" {
  description = "Region to deploy the resources"
  type        = string
}

variable "hosted_domain" {
  description = "Region to deploy the resources"
  type        = string
}

variable "app_domain" {
  description = "Region to deploy the resources"
  type        = string
}

variable "db_domain" {
  description = "Region to deploy the resources"
  type        = string
}