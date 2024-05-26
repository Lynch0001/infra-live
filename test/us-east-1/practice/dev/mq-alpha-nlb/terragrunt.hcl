terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "mq-alpha.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
  # nlb
  create = true
  enable_deletion_protection = false
  name = "mq-dev-a-nlb"
  internal = true
  load_balancer_type = "network"
  attach_asg = true
  #vpc_id # from region, env and cluster files
  #subnets # from region, env and cluster files
  #security_groups # from region, env and cluster files

  # nlb listeners
  listeners = {

    mqa1 = {
      port     = 7231
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-dev-a1-target"
      }
    }

    mqa2 = {
      port     = 7232
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-dev-a2-target"
      }
    }

    mqa3 = {
      port     = 7233
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-dev-a3-target"
      }
    }

    mqa4 = {
      port     = 7234
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-dev-a4-target"
      }
    }

    mqa5 = {
      port     = 7235
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-dev-a5-target"
      }
    }
  }

  # target groups
  target_groups = {
    # mqa1
    mq-dev-a1-target = {
      name_prefix = "mqda1-"
      protocol    = "TCP"
      port        = 7231
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqa2
    mq-dev-a2-target = {
      name_prefix = "mqda2-"
      protocol    = "TCP"
      port        = 7232
      target_id = ""
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqa3
    mq-dev-a3-target = {
      name_prefix = "mqda3-"
      protocol    = "TCP"
      port        = 7233
      target_id = ""
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqa4
    mq-dev-a4-target = {
      name_prefix = "mqda4-"
      protocol    = "TCP"
      port        = 7234
      target_id = ""
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqa5
    mq-dev-a5-target = {
      name_prefix = "mqda5-"
      protocol    = "TCP"
      port        = 7235
      target_id = ""
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
  }
  # create Route53 alias record for nlb
  route53_records = [{
    zone_id = local.env_vars.locals.zone_id
    name    = "${local.route53_record_name}"
    type    = "A"
  }]

  # tags
  tags = {
    Terraform = "true"
    Environment = "dev"
    Project = "alpha"
  }

  })
