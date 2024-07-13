# EC2 broom | Arief JR (arief.januar@broom.id)
output "id" {
  description = "The ID of the instance"
  value       = ["${aws_instance.broom.*.id}"]
}

output "arn" {
  description = "The ARN of the instance"
  value       = ["${aws_instance.broom.*.arn}"]
}

output "capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = ["${aws_instance.broom.*.capacity_reservation_specification}"]
}

output "instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = ["${aws_instance.broom.*.instance_state}"]
}

output "primary_network_interface_id" {
  description = "The ID of the instance's primary network interface"
  value       = ["${aws_instance.broom.*.primary_network_interface_id}"]
}

output "private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = ["${aws_instance.broom.*.private_dns}"]
}

output "public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = ["${aws_instance.broom.*.public_dns}"]
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = ["${aws_instance.broom.*.public_ip}"]
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = ["${aws_instance.broom.*.tags_all}"]
}

output "root_block_device" {
  description = "Root block device information"
  value       = ["${aws_instance.broom.*.root_block_device}"]
}

output "ebs_block_device" {
  description = "EBS block device information"
  value       = ["${aws_instance.broom.*.ebs_block_device}"]
}

output "ephemeral_block_device" {
  description = "Ephemeral block device information"
  value       = ["${aws_instance.broom.*.ephemeral_block_device}"]
}