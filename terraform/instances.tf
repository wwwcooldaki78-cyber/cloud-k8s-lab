resource "aws_instance" "dl_cp_01" {
  ami                         = "ami-04ccd752e0917a978"
  instance_type               = "c7i-flex.large"
  subnet_id                   = aws_subnet.pri_subnet_1.id
  private_ip                  = "192.168.3.69"
  vpc_security_group_ids      = [aws_security_group.dl_cp_sg.id]
  key_name                    = aws_key_pair.dl_cloud.key_name
  associate_public_ip_address = false
  source_dest_check           = false

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dl-cp"
  }
}

resource "aws_instance" "dl_wn_02" {
  ami                         = "ami-04ccd752e0917a978"
  instance_type               = "c7i-flex.large"
  subnet_id                   = aws_subnet.pri_subnet_1.id
  private_ip                  = "192.168.3.96"
  vpc_security_group_ids      = [aws_security_group.dl_wn_sg.id]
  key_name                    = aws_key_pair.dl_cloud.key_name
  associate_public_ip_address = false
  source_dest_check           = false
  iam_instance_profile        = aws_iam_instance_profile.k8s_worker_splunk_profile.name
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "dl-wn"
  }
}