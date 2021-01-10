resource "aws_instance" "web-1" {
    #ami = var.imagename
    count =  var.env!="prod" ? 1 : 6
    ami = "ami-0739f8cdb239fe9ae" 
    instance_type = "t2.micro"
    key_name = "raghavendra"
    availability_zone = element(var.azs,count.index)
    subnet_id = element(aws_subnet.subnets.*.id,count.index)
    vpc_security_group_ids = [aws_security_group.allow_all.id]
    associate_public_ip_address = true	
   tags = {
        Name = "${var.vpc_name}-server-${count.index+1}"
        Env = "prod"
        Owner = "raghu"
        Costcenter=8080
    }
}
resource "null_resource" "nginxinstallandcopy" {
    count =  var.env!="prod" ? 1 : 6
  provisioner "remote-exec" {
    inline = [
       "sudo apt-get update",
       "sudo apt-get -y install nginx"
    ]
  }
  connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("raghavendra.pem")
      host     =  aws_instance.web-1[count.index].public_ip
  }
}

resource "null_resource" "filecopy" {
    count =  var.env!="prod" ? 1 : 6
  provisioner "file" {
    source      = "saifile"
    destination = "/tmp/saifile"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("raghavendra.pem")
      host     =  aws_instance.web-1[count.index].public_ip
  }
  }
   provisioner "file" {
    source      = "raghutestfile"
    destination = "/tmp/raghutestfile"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("raghavendra.pem")
      host     =  aws_instance.web-1[count.index].public_ip
  }
  }
  provisioner "file" {
    source      = "testfile"
    destination = "/tmp/testfile"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("raghavendra.pem")
      host     =  aws_instance.web-1[count.index].public_ip
  }
  }
}

