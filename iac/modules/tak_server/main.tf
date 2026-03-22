data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-noble-24.04-*-server-*",
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-*-server-*",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "tak" {
  name_prefix = "tak-sg-"
  description = "TAK server access rules"
  vpc_id      = var.vpc_id

  ingress {
    description = "ATAK SSL streaming"
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Certificate enrollment"
    from_port   = 8446
    to_port     = 8446
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web UI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WebRTC video"
    from_port   = 8889
    to_port     = 8889
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WebRTC data"
    from_port   = 8189
    to_port     = 8189
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tak-sg"
  }
}

resource "aws_instance" "tak" {
  ami           = data.aws_ami.ubuntu_2404.id
  instance_type = var.instance_size
  subnet_id     = var.subnet_id

  vpc_security_group_ids      = [aws_security_group.tak.id]
  associate_public_ip_address = true

  user_data = templatefile(var.user_data_template, {
    ssh_username = var.admin_user
    ssh_password = var.admin_password
  })

  root_block_device {
    volume_size = var.ssd_size_gb
    volume_type = "gp3"
  }

  tags = {
    Name = "tak-server"
  }
}

resource "aws_eip" "tak" {
  domain = "vpc"
  tags = {
    Name = "tak-eip"
  }
}

resource "aws_eip_association" "tak" {
  allocation_id = aws_eip.tak.id
  instance_id   = aws_instance.tak.id
}
