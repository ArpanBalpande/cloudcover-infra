locals {
  name            = "cloudcover-${random_string.suffix.result}"
  cluster_version = "1.21"
  region          = "eu-west-1"
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
      instance_type                 = "t2.micro"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.micro"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    },
  ]

  # # Worker groups (using Launch Templates)
  # worker_groups_launch_template = [
  #   {
  #     name                    = "spot-1"
  #     override_instance_types = ["t2.micro"]
  #     spot_instance_pools     = 1
  #     asg_max_size            = 5
  #     asg_desired_capacity    = 5
  #     kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
  #     public_ip               = true
  #   },
  # ]

  # # Managed Node Groups
  # node_groups_defaults = {
  #   ami_type  = "AL2_x86_64"
  #   disk_size = 50
  # }

  # node_groups = {
  #   example = {
  #     desired_capacity = 1
  #     max_capacity     = 3
  #     min_capacity     = 1

  #     instance_types = ["t2.micro"]
  #     capacity_type  = "SPOT"
  #     k8s_labels = {
  #       Environment = "test"
  #       GithubRepo  = "terraform-aws-eks"
  #       GithubOrg   = "terraform-aws-modules"
  #     }
  #     additional_tags = {
  #       ExtraTag = "example"
  #     }
  #     taints = [
  #       {
  #         key    = "dedicated"
  #         value  = "gpuGroup"
  #         effect = "NO_SCHEDULE"
  #       }
  #     ]
  #     update_config = {
  #       max_unavailable_percentage = 50 # or set `max_unavailable`
  #     }
  #   }
  # }

  # # AWS Auth (kubernetes_config_map)
  # map_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::66666666666:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]

  # map_users = [
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user1"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user2"
  #     username = "user2"
  #     groups   = ["system:masters"]
  #   },
  # ]

  # map_accounts = [
  #   "777777777777",
  #   "888888888888",
  # ]

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Supporting resources
################################################################################

data "aws_availability_zones" "available" {
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}