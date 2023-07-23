/*
#ami id for us-west-2(amazon-linux2): ami-08541bb85074a743a
*/

#for use of existing key pair for authentication of instance
resource "aws_key_pair" "integration" {
  key_name   = "first"
  public_key = file("H:/ssh-key/terraform")
}


resource "aws_instance" "web" {
  ami           = "ami-08541bb85074a743a"
  instance_type = "t3.micro"
  key_name      = "terraform"
  tags = {
    Name = "Jenkins_integration"
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./terraform.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/home/ec2-user/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/script.sh",
      "/home/ec2-user/script.sh",
    ]
  }
}

output "jenkins_url" {

   value= "http://${aws_instance.web.public_ip}:8080"
  
}