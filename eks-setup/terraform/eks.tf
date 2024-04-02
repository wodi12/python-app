module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
        nodeAgent = {
          enablePolicyEventLogs = "true"
        }
        enableNetworkPolicy = "true"
      })
    }
    kube-proxy = {
        most_recent = true
    }
    coredns = {
        most_recent = true
    }        
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    default = {
      instance_types       = ["t2.small"]
      force_update_version = true
      release_version      = var.ami_release_version

      min_size     = 2
      max_size     = 3
      desired_size = 2

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        workshop-default = "yes"
      }
    }
  }

  tags = merge(local.tags, {
    "karpenter.sh/discovery" = var.cluster_name
  })
}

# module "eks_blueprints_addons" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons"
#   version = "~> 1.0" #ensure to update this to the latest/desired version

#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_version   = module.eks.cluster_version
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   eks_addons = {
#     aws-ebs-csi-driver = {
#       most_recent = true
#     }
#     coredns = {
#       most_recent = true
#     }
#     vpc-cni = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#   }

#   enable_aws_load_balancer_controller    = true
#   enable_cluster_proportional_autoscaler = true
#   enable_karpenter                       = true
#   enable_kube_prometheus_stack           = true
#   enable_metrics_server                  = true
#   enable_external_dns                    = true
#   enable_cert_manager                    = true
#   cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/*"]

#   tags = {
#     Environment = "webapp"
#   }
# }
