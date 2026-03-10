variable "name_prefix" {
  description = "Prefix for database resources"
  type        = string
}

variable "use_aurora" {
  description = "If true, create Aurora cluster; if false, create standard RDS instance"
  type        = bool
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ for standard RDS instance"
  type        = bool
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
}

variable "allowed_cidrs" {
  description = "CIDRs allowed to connect to the database"
  type        = list(string)
}