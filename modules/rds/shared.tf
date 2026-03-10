locals {
  db_port = contains(["mysql", "aurora-mysql"], var.engine) ? 3306 : 5432

  parameter_family = (
    var.engine == "postgres" ? "postgres16" :
    var.engine == "mysql" ? "mysql8.0" :
    var.engine == "aurora-postgresql" ? "aurora-postgresql16" :
    "aurora-mysql8.0"
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-subnet-group"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

resource "aws_db_parameter_group" "standard" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name_prefix}-parameter-group"
  family = local.parameter_family

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "work_mem"
    value = "4096"
  }

  tags = {
    Name = "${var.name_prefix}-parameter-group"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name_prefix}-cluster-parameter-group"
  family = local.parameter_family

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "work_mem"
    value = "4096"
  }

  tags = {
    Name = "${var.name_prefix}-cluster-parameter-group"
  }
}