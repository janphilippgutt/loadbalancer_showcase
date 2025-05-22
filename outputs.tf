output "load_balancer_dns" {
  value       = aws_lb.app_lb.dns_name
  description = "The DNS name of the public load balancer"
}

output "web1_public_ip" {
  value       = aws_instance.web1.public_ip
  description = "Public IP of Web Server 1"
}

output "web2_public_ip" {
  value       = aws_instance.web2.public_ip
  description = "Public IP of Web Server 2"
}
