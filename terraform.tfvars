variable "cidrs" { default = [] }

variable "amis" {
    type = "map"
    default = {
      "us-east-1" = "ami-b374d5a5"
    }
}