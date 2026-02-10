variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "services" {
  description = "List of microservices"
  type        = list(string)
}
