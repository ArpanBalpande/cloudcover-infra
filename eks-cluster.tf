locals {
  name            = "cloudcover-arpan"
  cluster_version = "1.21"
  region          = "eu-west-2"
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = [module.vpc.private_subnets[0], module.vpc.public_subnets[1]]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  # Worker groups (using Launch Configurations)
  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.large"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
  ]

  # AWS Auth (kubernetes_config_map)
  # map_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::66666666666:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]

  # map_users = [
  #   {
  #     userarn  = "arn:aws:iam::847370586410:user/arpan.balpande"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   }
  # ]

  # map_accounts = [
  #   "847370586410"
  # ]

  map_roles = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]

  map_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]

  map_accounts = [
    "777777777777",
    "888888888888",
  ]

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}