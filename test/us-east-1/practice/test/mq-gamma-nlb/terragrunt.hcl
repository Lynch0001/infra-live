terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "mq-gamma.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
  # nlb
  create = true
  enable_deletion_protection = false
  name = "mq-test-a-nlb"
  internal = true
  load_balancer_type = "network"
  attach_asg = true
  #vpc_id # from region, env and cluster files
  #subnets # from region, env and cluster files
  #security_groups # from region, env and cluster files

  # nlb listeners
  listeners = {

    mqg1 = {
      port     = 7241
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-g1-target"
      }
    }

    mqg2 = {
      port     = 7242
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-g2-target"
      }
    }

    mqg3 = {
      port     = 7243
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-g3-target"
      }
    }

    mqg4 = {
      port     = 7244
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-g4-target"
      }
    }

    mqg5 = {
      port     = 7245
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-g5-target"
      }
    }
  }

  # target groups
  target_groups = {
    # mqg1
    mq-test-g1-target = {
      name_prefix = "mqtg1-"
      protocol    = "TCP"
      port        = 7241
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqg2
    mq-test-g2-target = {
      name_prefix = "mqtg2-"
      protocol    = "TCP"
      port        = 7242
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqg3
    mq-test-g3-target = {
      name_prefix = "mqtg3-"
      protocol    = "TCP"
      port        = 7243
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqg4
    mq-test-g4-target = {
      name_prefix = "mqtg4-"
      protocol    = "TCP"
      port        = 7244
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqg5
    mq-test-g5-target = {
      name_prefix = "mqtg5-"
      protocol    = "TCP"
      port        = 7245
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
    Environment = "test"
    Project = "gamma"
  }

  })
