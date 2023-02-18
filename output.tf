
################################################################################
# Output
################################################################################
# Load Balancer Public URL
output "alb_url" {
  value = aws_lb.public.dns_name            #Requesr ALB DNS for testing
}