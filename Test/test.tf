variable "inst_type" {}
variable "nameofservers" {}

inst_type = "t3.small"

nameofservers = {
  mysql = {
    name      = "mysql"
    passsword = "RoboShop@1"
  }
}

data "aws_security_group" "allow-all" {
  name = "allow-all"
}

data "aws_ami" "centos_user" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners = ["973714476881"]
}

data "aws_security_group" "allow-all" {
  name = "allow-all"
}

resource "aws_instance" "ec2name" {
  ami           = data.aws_ami.centos_user.image_id
  instance_type = var.inst_type
  vpc_security_group_ids = [ data.aws_security_group.allow-all.id ]
  for_each = var.nameofservers

  tags = {
    Name = each.value["name"]
  }

}

resource "aws_route53_record" "records" {
  for_each = var.nameofservers

  zone_id = "Z104617622FGO6B5DAYVE"
  name    = "${each.value["name"]}-dev.kmvdevops.shop"
  type    = "A"
  ttl     = 30
  records = [aws_instance.ec2name[each.value["name"]].private_ip]
}


resource "null_resource" "followupresource" {

  depends_on = [aws_instance.ec2name, aws_route53_record.records]
  for_each = var.nameofservers
  connection {
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = aws_instance.ec2name[each.value["name"]].private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf roboshop-shell",
      "git clone https://github.com/Mohanvamsi-hub/roboshop-shell.git",
      "cd roboshop-shell",
      "echo ${each.value["name"]}.sh  ${lookup(each.value,"password","null")}",
      "sudo bash ${each.value["name"]}.sh  ${lookup(each.value,"password","null")}"
    ]
  }
}

