#Security Group
resource "aws_security_group" "web" {
    name = "starman-web-sg"
    vpc_id = var.vpc_id
    ingress { 
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0"]
    }
}

#IAM Role
resource "aws_iam_role" "ec2_role" {
    name = "Starman_ec2_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com"}}]
    })
}
resource "aws_iam_role_policy" "ec2_policy" {
  name = "portfolio_ec2_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permission 1: Read DynamoDB
      {
        Action   = ["dynamodb:GetItem", "dynamodb:Scan"]
        Effect   = "Allow"
        Resource = var.db_table_arn
      },
      # Permission 2: Allow Instance to Tag Itself (Rename)
      {
        Action   = "ec2:CreateTags"
        Effect   = "Allow"
        Resource = "*" # "Resource" must be * for CreateTags in AWS IAM rules
      }
    ]
  })
}

resource "aws_iam_instance_profile" "web_profile" { 
    name = "starman_profile"
    role = aws_iam_role.ec2_role.name
}

#Here we launch the template
resource "aws_launch_template" "web" {
    name_prefix = "starman-lt"
    image_id      = "ami-068c0051b15cdb816" # AL2023 us-east-1
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.web.id]
    iam_instance_profile {
         name = aws_iam_instance_profile.web_profile.name
         }
    #Injecting DB table name into the script
    user_data = base64encode(<<EOF
#!/bin/bash
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -sH "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
REGION="us-east-1"
dnf install -y httpd jq
systemctl start httpd
systemctl enable httpd 
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=Starman-Web-$INSTANCE_ID --region $REGION
TABLE_NAME="${var.db_table_name}"
SG=$(aws dynamodb get-item --table-name $TABLE_NAME --key '{"MessageId": {"S": "1"}}' --region $REGION --output json | jq -r '.Item.Content.S')
cat <<HTML > var/www/html/index.html 
<!DOCTYPE html>
<html><body>
<h1>Starman Board - A Modular Cloud Board</h1>
<p style="color: blue,">$MSG</p>
<p>Server: $(hostname -f) </p>
</body></html>
HTML
EOF
    )
}

resource "aws_autoscaling_group" "web"{
    desired_capacity = 3
    max_size = 4
    min_size = 1
    vpc_zone_identifier = [var.subnet_id] #variable from Networking
    launch_template { 
        id = aws_launch_template.web.id
        version = "$Latest"
    }
    tag { 
        key = "Name"
        value = "Starman-Web-Pending"
        propagate_at_launch = true
    }
}