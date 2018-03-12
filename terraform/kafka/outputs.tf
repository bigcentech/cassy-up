output "private_ips" {
  value = "${aws_instance.kafka.*.private_ip}"
}
