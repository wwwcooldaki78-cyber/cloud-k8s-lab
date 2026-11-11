resource "aws_lb_target_group" "http_tg" {
  name        = "dl-http-tg"
  target_type = "instance"
  protocol    = "TCP"
  port        = 32080
  vpc_id      = aws_vpc.vpc.id
  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }
  tags = {
    Name = "dl-http-tg"
  }
}
resource "aws_lb_target_group" "https_tg" {
  name        = "dl-https-tg"
  target_type = "instance"
  protocol    = "TCP"
  port        = 32443
  vpc_id      = aws_vpc.vpc.id

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = {
    Name = "dl-https-tg"
  }
}

resource "aws_lb_target_group_attachment" "http_wn" {
  target_group_arn = aws_lb_target_group.http_tg.arn
  target_id        = aws_instance.dl_wn_02.id
  port             = 32080
}
resource "aws_lb_target_group_attachment" "https_wn" {
  target_group_arn = aws_lb_target_group.https_tg.arn
  target_id        = aws_instance.dl_wn_02.id
  port             = 32443
}