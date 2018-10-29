output "ec2_ips" {
    value = "${aws_instance.uc1_ec2.*.public_ip}"
    description = "Public IPs of playground instances"
}