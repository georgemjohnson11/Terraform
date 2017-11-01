variable "cidrs" { 
  description   = "The default IP that will be applied to the EC2 Instance"
  default       = ["0.0.0.0/0"] 
}

variable "from_port" { 
  description   = "The default port that will be listening for the application"
  default       = "8080"
}

variable "to_port" { 
  description  = "The default port that will be listening for the application" 
  default      = "8080"
}