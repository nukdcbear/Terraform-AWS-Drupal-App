################################################
# Common
################################################
variable "friendly_name_prefix" {
  type        = string
  description = "String value for freindly name prefix for AWS resource names and tags"
  default     = "dcbear"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable AWS resources"
  default     = {}
}

################################################
# Network
################################################
variable "vpc_id" {
  type        = string
  description = "VPC ID that Drupal app will be deployed into"
  default     = "vpc-0ebb44d212c94dae4"
}


################################################
# Storage
################################################
variable "rds_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to use for RDS Database Subnet Group - preferably private subnets"
  default     = ["subnet-042cbf2b9863bdf4e", "subnet-0e30a970892d18361"]
}

variable "rds_storage_capacity" {
  type        = string
  description = "Size capacity (GB) of RDS PostgreSQL database"
  default     = 20
}

variable "rds_engine_version" {
  type        = string
  description = "Version of PostgreSQL for RDS engine"
  default     = "11"
}

variable "rds_multi_az" {
  type        = string
  description = "Set to true to enable multiple availability zone RDS"
  default     = "true"
}

variable "rds_instance_size" {
  type        = string
  description = "Instance size for RDS"
  default     = "db.m4.large"
}

################################################
# Security
################################################
variable "ingress_cidr_alb_allow" {
  type        = list(string)
  description = "List of CIDR ranges to allow web traffic ingress to Drupal Application Load Balancer (ALB)"
  default     = ["0.0.0.0/0"]
}

variable "ingress_cidr_ec2_allow" {
  type        = list(string)
  description = "List of CIDRs to allow SSH ingress to Drupal EC2 instance"
  default     = ["0.0.0.0/0"]
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to encrypt TFE S3 and RDS resources"
  default     = ""
}

variable "tfe_ecs_ssh_key_pair" {
  type        = string
  description = "Name of SSH key pair for Drupal EC2 instance"
  default     = "dcb-us-west-1"
}



