terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "io-artemis.tlynch.net"

  # for additional target attachment//io only
  # variable (verify) io box ec2 instances ids
  targets = ["i-0c1d444a981f3398c", "i-05259315c580e0778", "i-07776b32d772eb8f6"]
}

inputs = merge(
  local.env_vars.locals,
  local.region_vars.locals,
  {
    # nlb
    create = true
    enable_deletion_protection = false
    name = "io-test-artemis-nlb"
    internal = true
    load_balancer_type = "network"
    attach_asg = false
    #vpc_id # from region, env and cluster files
    #subnets # from region, env and cluster files
    #security_groups # from region, env and cluster files

    # target group only seems to attach one target with target_id; inactivated with create_attachment=false
    # consolidated all target attachments here
    additional_target_group_attachments = {
      add_target_a1 ={"target_group_key": "io-test-ar1-target", "target_id": local.targets[0], "port": 62623},
      add_target_a2 ={"target_group_key": "io-test-ar2-target", "target_id": local.targets[0], "port": 62626},
      add_target_a3 ={"target_group_key": "io-test-ar3-target", "target_id": local.targets[0], "port": 62627},
      add_target_a4 ={"target_group_key": "io-test-ar4-target", "target_id": local.targets[0], "port": 8162},
      add_target_a5 ={"target_group_key": "io-test-ar5-target", "target_id": local.targets[0], "port": 1099},
      add_target_b1 ={"target_group_key": "io-test-ar1-target", "target_id": local.targets[1], "port": 62623},
      add_target_b2 ={"target_group_key": "io-test-ar2-target", "target_id": local.targets[1], "port": 62626},
      add_target_b3 ={"target_group_key": "io-test-ar3-target", "target_id": local.targets[1], "port": 62627},
      add_target_b4 ={"target_group_key": "io-test-ar4-target", "target_id": local.targets[1], "port": 8162},
      add_target_b5 ={"target_group_key": "io-test-ar5-target", "target_id": local.targets[1], "port": 1099},
      add_target_c1 ={"target_group_key": "io-test-ar1-target", "target_id": local.targets[2], "port": 62623},
      add_target_c2 ={"target_group_key": "io-test-ar2-target", "target_id": local.targets[2], "port": 62626},
      add_target_c3 ={"target_group_key": "io-test-ar3-target", "target_id": local.targets[2], "port": 62627},
      add_target_c4 ={"target_group_key": "io-test-ar4-target", "target_id": local.targets[2], "port": 8162},
      add_target_c5 ={"target_group_key": "io-test-ar5-target", "target_id": local.targets[2], "port": 1099},
      #      add_target_d1 ={"target_group_key": "io-test-ar1-target", "target_id": local.targets[3], "port": 62623},
      #      add_target_d2 ={"target_group_key": "io-test-ar2-target", "target_id": local.targets[3], "port": 62626},
      #      add_target_d3 ={"target_group_key": "io-test-ar3-target", "target_id": local.targets[3], "port": 62627},
      #      add_target_d4 ={"target_group_key": "io-test-ar4-target", "target_id": local.targets[3], "port": 8162},
      #      add_target_d5 ={"target_group_key": "io-test-ar5-target", "target_id": local.targets[3], "port": 1099},
    }
    
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
      Project = "io"
    }

  })
