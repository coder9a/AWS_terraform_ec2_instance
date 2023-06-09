resource "aws_instance" "public-instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public-subnet.id
  key_name               = aws_key_pair.key-pair.id
  vpc_security_group_ids = ["${aws_security_group.public-sg.id}"]
  # user_data = file("${path.module}/script.sh")

  provisioner "file" {
    source      = "${var.project}_key.pem"
    destination = "/home/ubuntu/${var.project}_key.pem"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("${var.project}_key.pem")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /home/ubuntu/${var.project}_key.pem"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("${var.project}_key.pem")
    }
  }

  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "private-instance" {
  ami                    = var.ami
  count                  = var.instance_count
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private-subnet.id
  key_name               = aws_key_pair.key-pair.id
  vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]

  provisioner "file" {
    source      = "${var.project}_key.pem"
    destination = "/home/ubuntu/${var.project}_key.pem"

    connection {
      type         = "ssh"
      user         = "ubuntu"
      bastion_host = aws_instance.public-instance.public_ip
      host         = self.private_ip
      private_key  = file("${var.project}_key.pem")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /home/ubuntu/${var.project}_key.pem"
    ]
    connection {
      type         = "ssh"
      user         = "ubuntu"
      bastion_host = aws_instance.public-instance.public_ip
      host         = self.private_ip
      private_key  = file("${var.project}_key.pem")
    }
  }
  tags = {
    Name = "private-instance"
  }
}
