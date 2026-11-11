resource "aws_ec2_instance_connect_endpoint" "ssh" {
  subnet_id          = aws_subnet.pri_subnet_1.id
  security_group_ids = [aws_security_group.eice_sg.id]
  tags = {
    Name = "dl-ssh-endpoint"
  }
}
resource "aws_key_pair" "dl_cloud" {
  key_name   = "dl_cloud_ssh_key"
  public_key = file("../key/dl_cloud_ssh_key.pub")
}