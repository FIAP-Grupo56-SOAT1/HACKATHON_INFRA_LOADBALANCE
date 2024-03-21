variable "micro_servico" {
  description = "Nome do microserviço"
  type    = string
  default = "timesheet"
}


variable "regiao" {
  type    = string
  default = "us-east-1"
}

variable "containerDbPort" {
  description = "Porta do banco de dados do microserviço"
  type    = string
  default = "3306"
}

