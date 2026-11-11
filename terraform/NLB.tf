resource "aws_lb" "nlb" {
  name                             = "dl-nlb"
  internal                         = false
  load_balancer_type               = "network"
  ip_address_type                  = "ipv4"
  enable_cross_zone_load_balancing = true
  depends_on                       = [aws_internet_gateway.igw]
  subnet_mapping {
    subnet_id     = aws_subnet.pub_subnet_1.id
    allocation_id = aws_eip.nlb_eip.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.pub_subnet_2.id
  }
  security_groups = [aws_security_group.dl_nlb_sg.id]
  tags = {
    Name = "dl-nlb"
  }
}
resource "aws_lb_listener" "http_lis" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_tg.arn
  }
}
resource "aws_lb_listener" "https_lis" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https_tg.arn
  }
}