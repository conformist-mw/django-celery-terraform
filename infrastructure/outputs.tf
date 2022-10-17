output "production_lb_domain" {
  value = aws_lb.production.dns_name
}
