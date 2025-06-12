

variable "nameofservers" {}



resource "null_resource" "blank" {
  for_each = var.nameofservers
  provisioner "local-exec" {
    inline = [
      "rm -rf roboshop-shell",
      "git clone https://github.com/Mohanvamsi-hub/roboshop-shell.git",
      "cd roboshop-shell",
      "echo ${each.value["name"]}.sh  ${lookup(each.value,"password","null")}",
      #"sudo bash ${each.value["name"]}.sh  ${lookup(each.value,"password","null")}"
    ]
  }
}