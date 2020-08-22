resource "aws_instance" "web-1" {
    #ami = var.imagename
    count =  var.env!="prod" ? 1 : 6
    ami = "ami-0761dd91277e34178"
    instance_type = "t2.micro"
    key_name = "pawan123"
    availability_zone = element(var.azs,count.index)
    subnet_id = element(aws_subnet.subnets.*.id,count.index)
    vpc_security_group_ids = [aws_security_group.allow_all.id]
    associate_public_ip_address = true	
    tags = {
        Name = "${var.vpc_name}-server-${count.index+1}"
        Env = "prod"
        Owner = "Sree"
        Costcenter=8080
    }
}
