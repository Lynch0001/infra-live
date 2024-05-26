terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "mq-delta.tlynch.net"
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

    mqd1 = {
      port     = 7246
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-d1-target"
      }
    }

    mqd2 = {
      port     = 7247
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-d2-target"
      }
    }

    mqd3 = {
      port     = 7248
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-d3-target"
      }
    }

    mqd4 = {
      port     = 7249
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-d4-target"
      }
    }

    mqd5 = {
      port     = 7250
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-test-d5-target"
      }
    }
  }

  # target groups
  target_groups = {
    # mqd1
    mq-test-d1-target = {
      name_prefix = "mqtd1-"
      protocol    = "TCP"
      port        = 7246
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqd2
    mq-test-d2-target = {
      name_prefix = "mqtd2-"
      protocol    = "TCP"
      port        = 7247
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
    # mqd3
    mq-test-d3-target = {
      name_prefix = "mqtd3-"
      protocol    = "TCP"
      port        = 7248
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqd4
    mq-test-d4-target = {
      name_prefix = "mqtd4-"
      protocol    = "TCP"
      port        = 7249
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqd5
    mq-test-d5-target = {
      name_prefix = "mqtd5-"
      protocol    = "TCP"
      port        = 7250
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
    Project = "delta"
  }

  })
