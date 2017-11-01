provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "application" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  depends_on    = "["aws_s3_bucket.application"]
  provisioner "local_exec" {
    command     = "echo ${aws_instance.application.public_ip} > ip_address.txt"
  }
}
 
resource "aws_eip" "ip" {
  instance      = "${aws_instance.application.id}"
}

#associate an S3 bucket for the application
resource "aws_s3_bucket" "applicaiton" {
  bucket = "application_bucket"
  acl    = "private"
}
