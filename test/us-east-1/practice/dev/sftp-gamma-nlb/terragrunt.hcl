terraform {
  source = "git::git@github.com:Lynch0001/terraform-aws-alb.git//?ref=XX-mod-asg"
}

locals {
  cluster_vars = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  route53_record_name = "sftp-gamma.tlynch.net"
}

inputs = merge(
  local.cluster_vars.locals,
  local.env_vars.locals,
  local.region_vars.locals,
  {
  # nlb
  create = true
  enable_deletion_protection = false
  name = "sftp-dev-g-nlb"
  internal = true
  load_balancer_type = "network"
  attach_asg = true
  #vpc_id # from region, env and cluster files
  #subnets # from region, env and cluster files
  #security_groups # from region, env and cluster files

  # nlb listeners
  listeners = {

    sftpg = {
      port     = 22
      protocol = "TCP"
      forward  = {
        target_group_key = "sftp-dev-g-target"
      }
    }
  }
  # target groups
  target_groups = {
    # sftpg
    sftp-dev-a-target = {
      name_prefix = "sftg-"
      protocol    = "TCP"
      port        = 3022
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
    Project = "gamma"
  }
  })
