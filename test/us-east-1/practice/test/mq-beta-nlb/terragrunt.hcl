terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "mq-beta.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
  # nlb
  create = true
  enable_deletion_protection = false
  name = "mq-test-b-nlb"
  internal = true
  load_balancer_type = "network"
  attach_asg = true
  #vpc_id # from region, env and cluster files
  #subnets # from region, env and cluster files
  #security_groups # from region, env and cluster files

  # nlb listeners
  listeners = {

    mqb1 = {
      port     = 7236
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-b1-target"
      }
    }

    mqb2 = {
      port     = 7237
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-b2-target"
      }
    }

    mqb3 = {
      port     = 7238
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-b3-target"
      }
    }

    mqb4 = {
      port     = 7239
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-b4-target"
      }
    }

    mqb5 = {
      port     = 7240
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-b5-target"
      }
    }
  }

  # target groups
  target_groups = {
    # mqb1
    mq-test-b1-target = {
      name_prefix = "mqtb1-"
      protocol    = "TCP"
      port        = 7236
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqb2
    mq-test-b2-target = {
      name_prefix = "mqtb2-"
      protocol    = "TCP"
      port        = 7237
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqb3
    mq-test-b3-target = {
      name_prefix = "mqtb3-"
      protocol    = "TCP"
      port        = 7238
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqb4
    mq-test-b4-target = {
      name_prefix = "mqtb4-"
      protocol    = "TCP"
      port        = 7239
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqb5
    mq-test-b5-target = {
      name_prefix = "mqtb5-"
      protocol    = "TCP"
      port        = 7240
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
    Project = "beta"
  }

  })
