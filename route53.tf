
################################################################################
# Route53
################################################################################

#Hosted Zone 
resource "aws_route53_zone" "private" {
  name = var.hosted_domain
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.app_domain
  type    = "A"

  alias {
    name                   = aws_lb.private.dns_name
    zone_id                = aws_lb.private.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "rds" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.db_domain
  type    = "A"

  alias {
    name                   = aws_db_instance.rds.address
    zone_id                = aws_db_instance.rds.hosted_zone_id
    evaluate_target_health = true
  }
}