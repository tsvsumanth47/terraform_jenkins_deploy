/*
#ami id for us-west-2(amazon-linux2): ami-08541bb85074a743a
*/

#for use of key pair for authentication of instance
resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
#creation of keypair
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
#download key pair to local
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}


resource "aws_instance" "web" {
  ami           = "ami-08541bb85074a743a"
  instance_type = "t3.micro"
  key_name = "tf-key-pair"
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
