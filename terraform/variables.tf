variable "project_name" {
  description = "Name of project"
  type = string
  default = "python-app"  
}

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t2.micro"  
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "ohio-key"
}

variable "subnet_ids" {
  type = list
  default = ["subnet-08097e04211f22c2d", "subnet-0e39f0f8095725cb4", "subnet-08160280f6c3366f9"]
}

variable "vpc_id" {
    default = "vpc-05b73b4064618b9e3"
}