terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "io-activemq.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
    # nlb
    create = true
    enable_deletion_protection = false
    name = "io-test-activemq-nlb"
    internal = true
    load_balancer_type = "network"
    attach_asg = true
    #vpc_id # from region, env and cluster files
    #subnets # from region, env and cluster files
    #security_groups # from region, env and cluster files

    # nlb listeners
    listeners = {

      jms1 = {
        port     = 61616
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-aq1-target"
        }
      }

      jms2 = {
        port     = 61617
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-aq2-target"
        }
      }

      con3 = {
        port     = 8161
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-aq3-target"
        }
      }
    }
    # target groups
    target_groups = {
      # jms1
      io-test-aq1-target = {
        name_prefix = "itaq1-"
        protocol    = "TCP"
        port        = 61616
        create_attachment = false
        health_check = {
          enabled = true
          port = 61616
          protocol = "TCP"
        }
      }
      # jms2
      io-test-aq2-target = {
        name_prefix = "itaq2-"
        protocol    = "TCP"
        port        = 61617
        create_attachment = false
        health_check = {
          enabled = true
          port = 61617
          protocol = "TCP"
        }
      }
      # con1
      io-test-aq3-target = {
        name_prefix = "itaqc-"
        protocol    = "TCP"
        port        = 8161
        create_attachment = false
        health_check = {
          enabled = true
          port = 8161
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
