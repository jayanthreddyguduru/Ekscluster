#New Vpc Creation which includes cidr range of 10.0.0.0/16 in us-east-1 region
#the vpc has 2 public and 2 private subnets.
#Nat gatewat and dns hostnames have been enabled.

variable "region" {
    default = "us-east-1"
}

data "aws_availability_zones" "available" {}

locals {
    cluster_name = "EKS-Cluster-test"
}

module vpc {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.19.0"
    
    name = "EKS-VPC"
    
    cidr = "10.0.0.0/16"
    azs  = slice(data.aws_availability_zones.available.names, 0, 3)
    
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", ]
    public_subnets =  ["10.0.3.0/24", "10.0.4.0/24", ]
    
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    
    tags = {
        "Name" = "EKS-VPC"
    }

    public_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                      = 1
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb"             = 1
    }
}