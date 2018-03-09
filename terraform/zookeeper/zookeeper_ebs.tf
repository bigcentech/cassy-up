resource "aws_ebs_volume" "zookeeper-ebs" {
  count             = "${var.count}"
  availability_zone = "${element(aws_instance.zookeeper.*.availability_zone, count.index)}"
  size              = "${var.ebs_size_per_node}"
  type              = "${var.ebs_type}"

  tags {
    Name = "${format("%s-ebs-%d", var.tag_name, count.index + 1)}"
  }
}

resource "aws_volume_attachment" "zookeeper-ebs-attach" {
  count        = "${var.count}"
  device_name  = "/dev/xvdh"
  volume_id    = "${element(aws_ebs_volume.zookeeper-ebs.*.id, count.index)}"
  instance_id  = "${element(aws_instance.zookeeper.*.id, count.index)}"
  force_detach = true
}
