# ==============================================================================
# 01. Security Groups - I have four here
# ==============================================================================
resource "aws_security_group" "dl_cp_sg" {
  name        = "dl-cp-sg"
  description = "Security group for the control-plane"
  vpc_id      = aws_vpc.vpc.id
}
resource "aws_vpc_security_group_egress_rule" "allow_all_cp" {
  security_group_id = aws_security_group.dl_cp_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "cp_ssh" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.eice_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow ssh access from the Endpoint"
}
resource "aws_vpc_security_group_ingress_rule" "cp_dns_tcp" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "tcp"
  description                  = "For DNS, worker node needs it"
}
resource "aws_vpc_security_group_ingress_rule" "cp_dns_udp" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "udp"
  description                  = "For DNS, worker node needs it"
}
resource "aws_vpc_security_group_ingress_rule" "cp_rt_ex" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 179
  to_port                      = 179
  ip_protocol                  = "tcp"
  description                  = "Need this port open for route exchange"
}
resource "aws_vpc_security_group_ingress_rule" "cp_rt_ex_f" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  from_port                    = 179
  to_port                      = 179
  ip_protocol                  = "tcp"
  description                  = "Need this port open for route exchange in the future if I add another control plane."
}
resource "aws_vpc_security_group_ingress_rule" "cp_vxlan" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 4789
  to_port                      = 4789
  ip_protocol                  = "udp"
  description                  = "Calico VXLAN from worker"
}
resource "aws_vpc_security_group_ingress_rule" "cp_typha" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 5473
  to_port                      = 5473
  ip_protocol                  = "tcp"
  description                  = "Typha sync for calico confd"
}
resource "aws_vpc_security_group_ingress_rule" "cp_kube_acc" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  description                  = "Worker kubelet/kube-proxy register & watch"
}
resource "aws_vpc_security_group_ingress_rule" "cp_cp_f" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "In future, if I ever need to add another control plane"
}
resource "aws_vpc_security_group_ingress_rule" "cp_cp_f_proff" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  ip_protocol                  = "4"
  description                  = "Future-proofing control plane with control plane"
}
resource "aws_vpc_security_group_ingress_rule" "cp_wn_f_proff" {
  security_group_id            = aws_security_group.dl_cp_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  ip_protocol                  = "4"
  description                  = "Future-proofing control plane with worker node"
}
# ==============================================================================
# ==============================================================================
# ==============================================================================
resource "aws_security_group" "dl_nlb_sg" {
  name        = "dl-nlb-sg"
  description = "Security group for the network load balancer"
  vpc_id      = aws_vpc.vpc.id
}
resource "aws_vpc_security_group_egress_rule" "allow_all_nlb" {
  security_group_id = aws_security_group.dl_nlb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "nlb_http" {
  security_group_id = aws_security_group.dl_nlb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow http traffic from the internet"
}
resource "aws_vpc_security_group_ingress_rule" "nlb_https" {
  security_group_id = aws_security_group.dl_nlb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow https traffic from the internet"
}
# ==============================================================================
# ==============================================================================
# ==============================================================================
resource "aws_security_group" "dl_wn_sg" {
  name        = "dl-wn-sg"
  description = "Security group for the worker node"
  vpc_id      = aws_vpc.vpc.id
}
resource "aws_vpc_security_group_egress_rule" "allow_all_wn" {
  security_group_id = aws_security_group.dl_wn_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "wn_ssh" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.eice_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow ssh access from the endpoint"
}
resource "aws_vpc_security_group_ingress_rule" "wn_dns_tcp" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "tcp"
  description                  = "For DNS, worker node needs it"
}
resource "aws_vpc_security_group_ingress_rule" "wn_dns_udp" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 53
  to_port                      = 53
  ip_protocol                  = "udp"
  description                  = "For DNS, worker node needs it"
}
resource "aws_vpc_security_group_ingress_rule" "wn_rt_ex" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 179
  to_port                      = 179
  ip_protocol                  = "tcp"
  description                  = "In future, if I decided to have another worker node"
}
resource "aws_vpc_security_group_ingress_rule" "wn_rt_ex_f" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  from_port                    = 179
  to_port                      = 179
  ip_protocol                  = "tcp"
  description                  = "Pod traffic to/from control plane"
}
resource "aws_vpc_security_group_ingress_rule" "wn_vxlan" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  from_port                    = 4789
  to_port                      = 4789
  ip_protocol                  = "udp"
  description                  = "Calico VXLAN"
}
resource "aws_vpc_security_group_ingress_rule" "wn_cp_kube" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "Api server need access to kubelet of worker node"
}
resource "aws_vpc_security_group_ingress_rule" "nlb_http_acc" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_nlb_sg.id
  from_port                    = 32080
  to_port                      = 32080
  ip_protocol                  = "tcp"
  description                  = "Need this for NLB to send traffic to this port"
}
resource "aws_vpc_security_group_ingress_rule" "nlb_https_acc" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_nlb_sg.id
  from_port                    = 32443
  to_port                      = 32443
  ip_protocol                  = "tcp"
  description                  = "Need this for NLB to send traffic to this port"
}
resource "aws_vpc_security_group_ingress_rule" "wn_cp_f_proff" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  ip_protocol                  = "4"
  description                  = "Future-proofing control plane with control plane"
}
resource "aws_vpc_security_group_ingress_rule" "wn_wn_f_proff" {
  security_group_id            = aws_security_group.dl_wn_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  ip_protocol                  = "4"
  description                  = "Future-proofing control plane with worker node"
}
# ==============================================================================
# ==============================================================================
# ==============================================================================
resource "aws_security_group" "eice_sg" {
  name        = "dl-eice-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.vpc.id
}
resource "aws_vpc_security_group_egress_rule" "eice_to_cp" {
  security_group_id            = aws_security_group.eice_sg.id
  referenced_security_group_id = aws_security_group.dl_cp_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow traffic from the endpoint to control-plane"
}
resource "aws_vpc_security_group_egress_rule" "eice_to_wn" {
  security_group_id            = aws_security_group.eice_sg.id
  referenced_security_group_id = aws_security_group.dl_wn_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow traffic from the endpoint to worker-node"
}