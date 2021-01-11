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
resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.default.id
}

/*resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id        = "${var.instance1_id}"
  port             = 80
}
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id        = "${var.instance2_id}"
  port             = 80
}*/
resource "aws_lb" "my-aws-alb" {
  name     = "my-test-alb"
  internal = false

  security_groups = [aws_security_group.allow_all.id]

  subnets = aws_subnet.subnets.*.id
  tags = {
    Name = "my-test-alb"
  }
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}
resource "aws_launch_configuration" "example" {
  image_id               = "ami-0739f8cdb239fe9ae"
  instance_type          = "t2.micro"
  security_groups        = [aws_security_group.allow_all.id]
  key_name               = "raghavendra"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
   vpc_zone_identifier = aws_subnet.subnets.*.id
  min_size = 2
  max_size = 10
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
