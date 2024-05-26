terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "mq.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
  # nlb
  create = true
  enable_deletion_protection = false
  name = "mq-perf-nlb"
  internal = true
  load_balancer_type = "network"
  attach_asg = true
  #vpc_id # from region, env and cluster files
  #subnets # from region, env and cluster files
  #security_groups # from region, env and cluster files

  # nlb listeners
  listeners = {

    mqa = {
      port     = 7231
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-perf-a-target"
      }
    }

    mqb = {
      port     = 7232
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-perf-b-target"
      }
    }

    mqc = {
      port     = 7233
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-perf-c-target"
      }
    }

    mqd = {
      port     = 7234
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-perf-d-target"
      }
    }

    mqe = {
      port     = 7235
      protocol = "TCP"
      forward  = {
        target_group_key = "mq-perf-e-target"
      }
    }
  }

  # target groups
  target_groups = {
    # mqa
    mq-perf-a-target = {
      name_prefix = "mqta-"
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
    # mqb
    mq-perf-b-target = {
      name_prefix = "mqtb-"
      protocol    = "TCP"
      port        = 7232
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqc
    mq-perf-c-target = {
      name_prefix = "mqtc-"
      protocol    = "TCP"
      port        = 7233
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqd
    mq-perf-d-target = {
      name_prefix = "mqtd-"
      protocol    = "TCP"
      port        = 7234
      create_attachment = false
      health_check = {
        enabled = true
        port = 80
        path = "/healthz"
        protocol = "HTTP"
        matcher = "200-399"
      }
    }
    # mqe
    mq-perf-e-target = {
      name_prefix = "mqte-"
      protocol    = "TCP"
      port        = 7235
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
    Environment = "perf"
  }

  })
