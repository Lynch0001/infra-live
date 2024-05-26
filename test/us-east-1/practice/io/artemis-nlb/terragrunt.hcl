terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "io-artemis.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
    # nlb
    create = true
    enable_deletion_protection = false
    name = "io-test-artemis-nlb"
    internal = true
    load_balancer_type = "network"
    attach_asg = true
    #vpc_id # from region, env and cluster files
    #subnets # from region, env and cluster files
    #security_groups # from region, env and cluster files

    # nlb listeners
    listeners = {

      jms1 = {
        port     = 62623
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-ar1-target"
        }
      }

      jms2 = {
        port     = 62626
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-ar2-target"
        }
      }

      jms3 = {
        port     = 62627
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-ar3-target"
        }
      }

      con4 = {
        port     = 8162
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-ar4-target"
        }
      }

      jmx5 = {
        port     = 1099
        protocol = "TCP"
        forward  = {
          target_group_key = "io-test-ar5-target"
        }
      }
    }

    # target groups
    target_groups = {
      # jms1
      io-test-ar1-target = {
        name_prefix = "itar1-"
        protocol    = "TCP"
        port        = 62623
        create_attachment = false
        health_check = {
          enabled = true
          port = 62623
          protocol = "TCP"
        }
      }
      # jms2
      io-test-ar2-target = {
        name_prefix = "itar2-"
        protocol    = "TCP"
        port        = 62626
        create_attachment = false
        health_check = {
          enabled = true
          port = 62626
          protocol = "TCP"
        }
      }
      # jms3
      io-test-ar3-target = {
        name_prefix = "itar3-"
        protocol    = "TCP"
        port        = 62627
        create_attachment = false
        health_check = {
          enabled = true
          port = 62627
          protocol = "TCP"
        }
      }
      # con4
      io-test-ar4-target = {
        name_prefix = "itar4-"
        protocol    = "TCP"
        port        = 8162
        create_attachment = false
        health_check = {
          enabled = true
          port = 8162
          protocol = "TCP"
        }
      }
      # jmx5
      io-test-ar5-target = {
        name_prefix = "itar5-"
        protocol    = "TCP"
        port        = 1099
        create_attachment = false
        health_check = {
          enabled = true
          port = 1099
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
