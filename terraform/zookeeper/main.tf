resource "aws_instance" "zookeeper" {
  count                  = "${var.count}"
  ami                    = "${var.ami_id}"
  key_name               = "${var.ssh_key_pair_name}"
  instance_type          = "${var.instance_type}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  subnet_id              = "${element(var.subnet_ids, count.index % length(var.subnet_ids))}"
  vpc_security_group_ids = ["${var.sg_ids}"]

  tags = {
    Name = "${format("%s-%d", var.tag_name, count.index + 1)}"
  }
}

resource "null_resource" "provision-zookeeper-ebs" {
  count = "${var.count}"

  depends_on = ["aws_volume_attachment.zookeeper-ebs-attach"]

  connection {
    user        = "${var.ssh_user}"
    host        = "${element(aws_instance.zookeeper.*.private_ip, count.index)}"
    agent       = true
    private_key = "${file("${var.ssh_key_pair_file}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/lib/zookeeper",
      "sudo apt-get install xfsprogs -y",
      "sudo mkfs.xfs -f -s size=4096 -d sunit=8 -d swidth=256 /dev/xvdh",
      "sudo mount -t xfs /dev/xvdh /var/lib/zookeeper",
      "printf '/dev/xvdh\t/var/lib/zookeeper\txfs\tdefaults\t0 0' | sudo tee --append /etc/fstab",
    ]
  }
}

resource "null_resource" "provision-zookeeper" {
  count = "${var.count}"

  depends_on = ["null_resource.provision-zookeeper-ebs"]

  triggers {
    revision = "${var.rev}"
  }

  connection {
    user        = "${var.ssh_user}"
    host        = "${element(aws_instance.zookeeper.*.private_ip, count.index)}"
    agent       = true
    private_key = "${file("${var.ssh_key_pair_file}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/cassy-up",
      "sudo service zookeeper stop || true",
      "sudo rm -rf /opt/zookeeper/* || true",
      "sudo rm -rf /tmp/cassy-up/*",
      "sudo rm /etc/init.d/zookeeper || true",
    ]
  }

  provisioner "file" {
    source      = "${var.provisioning_scripts}/oracle-jdk"
    destination = "/tmp/cassy-up"
  }

  provisioner "file" {
    source      = "${var.provisioning_scripts}/environments/aws/oracle-jdk.sh"
    destination = "/tmp/cassy-up/oracle-jdk.sh"
  }

  provisioner "file" {
    source      = "${var.provisioning_scripts}/apache-zookeeper"
    destination = "/tmp/cassy-up"
  }

  provisioner "file" {
    source      = "${var.provisioning_scripts}/environments/aws/zookeeper.sh"
    destination = "/tmp/cassy-up/zookeeper.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "echo 'export ZOOKEEPER_MY_ID=${count.index+1}' >> /tmp/cassy-up/zookeeper_params.sh",
      "echo 'export ZOOKEEPER_SERVERS=${join(",", aws_instance.zookeeper.*.private_ip)}' >> /tmp/cassy-up/zookeeper_params.sh",
      "chmod -R a+x /tmp/cassy-up/*",
      "sudo /tmp/cassy-up/oracle-jdk.sh",
      "sudo /tmp/cassy-up/zookeeper.sh",
    ]
  }

  # Installation log
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "source /tmp/cassy-up/zookeeper_params.sh",
      "source /tmp/cassy-up/apache-zookeeper/zookeeper-params.sh",
      "echo \"revision: ${var.rev}\" | sudo tee /opt/zookeeper/install.yaml",
      "echo \"zk:\" | sudo tee --append /opt/zookeeper/install.yaml",
      "echo \"  id: $ZOOKEEPER_MY_ID\" | sudo tee --append /opt/zookeeper/install.yaml",
      "echo \"  version: $ZOOKEEPER_VERSION\" | sudo tee --append /opt/zookeeper/install.yaml",
      "echo \"  dir: $ZOOKEEPER_DIR\" | sudo tee --append /opt/zookeeper/install.yaml",
      "echo \"  download_dir: $ZOOKEEPER_DOWNLOAD_DIR\" | sudo tee --append /opt/zookeeper/install.yaml",
      "echo \"  download_url: $ZOOKEEPER_URL\" | sudo tee --append /opt/zookeeper/install.yaml",
      "echo \"  install_dir: $ZOOKEEPER_INSTALL_DIR\" | sudo tee --append /opt/zookeeper/install.yaml",
      "echo \"  data_dir: $ZOOKEEPER_DATA_DIR\" | sudo tee --append $ZOOKEEPER_DIR/install.yaml",
      "echo \"  log_dir: $ZOOKEEPER_LOG_DIR\" | sudo tee --append $ZOOKEEPER_DIR/install.yaml",
    ]
  }
}
