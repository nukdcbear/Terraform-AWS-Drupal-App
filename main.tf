data "aws_caller_identity" "current" {}

################################################
# Security Groups
################################################
resource "aws_security_group" "drupal_alb_allow" {
  name   = "${var.friendly_name_prefix}-drupal-alb-allow"
  vpc_id = var.vpc_id
  tags   = merge({ Name = "${var.friendly_name_prefix}-drupal-alb-allow" }, var.common_tags)
}

resource "aws_security_group_rule" "drupal_alb_allow_inbound_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.ingress_cidr_alb_allow
  description = "Allow HTTPS (port 443) traffic inbound to Drupal ALB"

  security_group_id = aws_security_group.drupal_alb_allow.id
}

resource "aws_security_group_rule" "drupal_alb_allow_inbound_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = var.ingress_cidr_alb_allow
  description = "Allow HTTP (port 80) traffic inbound to Drupal ALB"

  security_group_id = aws_security_group.drupal_alb_allow.id
}

resource "aws_security_group_rule" "drupal_alb_allow_inbound_console" {
  type        = "ingress"
  from_port   = 8800
  to_port     = 8800
  protocol    = "tcp"
  cidr_blocks = var.ingress_cidr_alb_allow
  description = "Allow admin console (port 8800) traffic inbound to Drupal ALB for Drupal Replicated app"

  security_group_id = aws_security_group.drupal_alb_allow.id
}

resource "aws_security_group" "drupal_ec2_allow" {
  name   = "${var.friendly_name_prefix}-drupal-ec2-allow"
  vpc_id = var.vpc_id
  tags   = merge({ Name = "${var.friendly_name_prefix}-drupal-ec2-allow" }, var.common_tags)
}

resource "aws_security_group_rule" "drupal_ec2_allow_https_inbound_from_alb" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.drupal_alb_allow.id
  description              = "Allow HTTPS (port 443) traffic inbound to Drupal EC2 instance from Drupal Appication Load Balancer"

  security_group_id = aws_security_group.drupal_ec2_allow.id
}

resource "aws_security_group_rule" "drupal_ec2_allow_inbound_ssh" {
  count       = length(var.ingress_cidr_ec2_allow) > 0 ? 1 : 0
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.ingress_cidr_ec2_allow
  description = "Allow SSH inbound to Drupal EC2 instance CIDR ranges listed"

  security_group_id = aws_security_group.drupal_ec2_allow.id
}

resource "aws_security_group_rule" "drupal_ec2_allow_8800_inbound_from_alb" {
  type                     = "ingress"
  from_port                = 8800
  to_port                  = 8800
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.drupal_alb_allow.id
  description              = "Allow admin console (port 8800) traffic inbound to Drupal EC2 instance from Drupal Appication Load Balancer"

  security_group_id = aws_security_group.drupal_ec2_allow.id
}

resource "aws_security_group" "drupal_rds_allow" {
  name   = "${var.friendly_name_prefix}-drupal-rds-allow"
  vpc_id = var.vpc_id
  tags   = merge({ Name = "${var.friendly_name_prefix}-drupal-rds-allow" }, var.common_tags)
}

resource "aws_security_group_rule" "drupal_rds_allow_pg_from_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.drupal_ec2_allow.id
  description              = "Allow PostgreSQL traffic inbound to Drupal RDS from Drupal EC2 Security Group"

  security_group_id = aws_security_group.drupal_rds_allow.id
}

################################################
# RDS
################################################
resource "aws_db_subnet_group" "drupal_rds_subnet_group" {
  name       = "${var.friendly_name_prefix}-drupal-db-subnet-group"
  subnet_ids = var.rds_subnet_ids

  tags = merge(
    { Name = "${var.friendly_name_prefix}-drupal-db-subnet-group" },
    { Description = "Subnets for Drupal PostgreSQL RDS instance" },
    var.common_tags
  )
}

resource "random_password" "rds_password" {
  length  = 24
  special = false
}

resource "aws_db_instance" "drupal_rds" {
  allocated_storage         = var.rds_storage_capacity
  identifier                = "${var.friendly_name_prefix}-drupal-rds-${data.aws_caller_identity.current.account_id}"
  final_snapshot_identifier = "${var.friendly_name_prefix}-drupal-rds-${data.aws_caller_identity.current.account_id}-final-snapshot"
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = var.rds_engine_version
  db_subnet_group_name      = aws_db_subnet_group.drupal_rds_subnet_group.id
  name                      = "drupal"
  storage_encrypted         = true
  kms_key_id                = var.kms_key_arn != "" ? var.kms_key_arn : ""
  multi_az                  = var.rds_multi_az
  instance_class            = var.rds_instance_size
  username                  = "drupal"
  password                  = random_password.rds_password.result

  vpc_security_group_ids = [
    aws_security_group.drupal_rds_allow.id
  ]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-drupal-rds-${data.aws_caller_identity.current.account_id}" },
    { Description = "Drupal PostgreSQL database storage" },
    var.common_tags
  )
}
