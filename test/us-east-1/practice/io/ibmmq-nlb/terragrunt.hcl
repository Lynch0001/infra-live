terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "io-mq.tlynch.net"

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
    name = "io-test-ibmmq-nlb"
    internal = true
    load_balancer_type = "network"
    attach_asg = false
    #vpc_id # from region, env and cluster files
    #subnets # from region, env and cluster files
    #security_groups # from region, env and cluster files

    # target group only seems to attach one target with target_id; inactivated with create_attachment=false
    # consolidated all target attachments here
    additional_target_group_attachments = {
      add_target_a1 ={"target_group_key": "io-test-iq1-target", "target_id": local.targets[0], "port": 7231},
      add_target_a2 ={"target_group_key": "io-test-iq2-target", "target_id": local.targets[0], "port": 7232},
      add_target_a3 ={"target_group_key": "io-test-iq3-target", "target_id": local.targets[0], "port": 7233},
      add_target_a4 ={"target_group_key": "io-test-iq4-target", "target_id": local.targets[0], "port": 7234},
      add_target_a5 ={"target_group_key": "io-test-iq5-target", "target_id": local.targets[0], "port": 7235},
      add_target_b1 ={"target_group_key": "io-test-iq1-target", "target_id": local.targets[1], "port": 7231},
      add_target_b2 ={"target_group_key": "io-test-iq2-target", "target_id": local.targets[1], "port": 7232},
      add_target_b3 ={"target_group_key": "io-test-iq3-target", "target_id": local.targets[1], "port": 7233},
      add_target_b4 ={"target_group_key": "io-test-iq4-target", "target_id": local.targets[1], "port": 7234},
      add_target_b5 ={"target_group_key": "io-test-iq5-target", "target_id": local.targets[1], "port": 7235},
      add_target_c1 ={"target_group_key": "io-test-iq1-target", "target_id": local.targets[2], "port": 7231},
      add_target_c2 ={"target_group_key": "io-test-iq2-target", "target_id": local.targets[2], "port": 7232},
      add_target_c3 ={"target_group_key": "io-test-iq3-target", "target_id": local.targets[2], "port": 7233},
      add_target_c4 ={"target_group_key": "io-test-iq4-target", "target_id": local.targets[2], "port": 7234},
      add_target_c5 ={"target_group_key": "io-test-iq5-target", "target_id": local.targets[2], "port": 7235},
#      add_target_d1 ={"target_group_key": "io-test-iq1-target", "target_id": local.targets[3], "port": 7231},
#      add_target_d2 ={"target_group_key": "io-test-iq2-target", "target_id": local.targets[3], "port": 7232},
#      add_target_d3 ={"target_group_key": "io-test-iq3-target", "target_id": local.targets[3], "port": 7233},
#      add_target_d4 ={"target_group_key": "io-test-iq4-target", "target_id": local.targets[3], "port": 7234},
#      add_target_d5 ={"target_group_key": "io-test-iq5-target", "target_id": local.targets[3], "port": 7235},
    }

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
      Project = "io"
    }

  })
