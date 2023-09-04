# Terraform-Project-1
created EC2 instance, deploy it on a custom vpc on a custom subnet and assign it a public ip address so that not only can we SSH to it and connect to it and make changes to it.
Automatically set up a web server to run on it so that we can handle web traffic


#steps
on AWS account, set up new access key
create vpc
Create internet gateway
create custom Route Table
create a subnet
Associate subnet with route Table
Create Security Group to allow port 22, 80 & 443
Create a network Interface with an Ip in the subnet that was created in step 5
Assign an elastic IP to the network interface created in step 8
Create Ubuntu server and insall/enable Apache2
