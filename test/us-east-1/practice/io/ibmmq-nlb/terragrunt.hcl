terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "io-mq.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
    # nlb
    create = true
    enable_deletion_protection = false
    name = "io-test-ibmmq-nlb"
    internal = true
    load_balancer_type = "network"
    attach_asg = true
    #vpc_id # from region, env and cluster files
    #subnets # from region, env and cluster files
    #security_groups # from region, env and cluster files

    # nlb listeners
    listeners = {

      imq1 = {
        port     = 7231
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-iq1-target"
        }
      }

      imq2 = {
        port     = 7232
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-iq2-target"
        }
      }

      imq3 = {
        port     = 7233
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-iq3-target"
        }
      }

      imq4 = {
        port     = 7234
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-iq4-target"
        }
      }

      imq5 = {
        port     = 7235
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-iq5-target"
        }
      }
    }

    # target groups
    target_groups = {
      # imq1
      io-test-iq1-target = {
        name_prefix = "itiq1-"
        protocol    = "TCP"
        port        = 7231
        create_attachment = false
        health_check = {
          enabled = true
          port = 7231
          protocol = "TCP"
        }
      }
      # imq2
      io-test-iq2-target = {
        name_prefix = "itiq2-"
        protocol    = "TCP"
        port        = 7232
        create_attachment = false
        health_check = {
          enabled = true
          port = 7232
          protocol = "TCP"
        }
      }
      # imq3
      io-test-iq3-target = {
        name_prefix = "itiq3-"
        protocol    = "TCP"
        port        = 7233
        create_attachment = false
        health_check = {
          enabled = true
          port = 7233
          protocol = "TCP"
        }
      }
      # imq4
      io-test-iq4-target = {
        name_prefix = "itiq4-"
        protocol    = "TCP"
        port        = 7234
        create_attachment = false
        health_check = {
          enabled = true
          port = 7234
          protocol = "TCP"
        }
      }
      # imq5
      io-test-iq5-target = {
        name_prefix = "itiq5-"
        protocol    = "TCP"
        port        = 7235
        create_attachment = false
        health_check = {
          enabled = true
          port = 7235
          protocol = "TCP"
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
      Project = "alpha"
    }

  })
