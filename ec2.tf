
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.pub_subnet.id}"
  key_name      = "${aws_key_pair.bastion.key_name}"
  security_groups = ["${aws_security_group.allow_ssh.id}"]

  tags = {
    Name = "bastion"
  }
}


resource "aws_instance" "eks_master" {
  count         = 1
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.pvt_subnet.id}"
  key_name      = "${aws_key_pair.bastion.key_name}"
  security_groups = ["${aws_security_group.allow_ssh.id}"]


  tags = {
    Name = "eks master"
  }
}

resource "aws_instance" "eks_worker" {
  count         = 1
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.pvt_subnet.id}"
  key_name      = "${aws_key_pair.bastion.key_name}"
  security_groups = ["${aws_security_group.allow_ssh.id}"]

  tags = {
    Name = "eks worker"
  }
}

