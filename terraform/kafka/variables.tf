variable rev {}

variable count {}
variable tag_name {}

variable ebs_size_per_node {}
variable ebs_type {}

variable ami_id {}
variable instance_type {}
variable iam_instance_profile {}

variable subnet_ids {
  type = "list"
}

variable sg_ids {
  type = "list"
}

variable provisioning_scripts {}
variable ssh_user {}
variable ssh_key_pair_name {}
variable ssh_key_pair_file {}

variable zk_ips {
  type = "list"
}
