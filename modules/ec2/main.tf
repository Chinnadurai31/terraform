
resource "aws_instance" "test_instance" {
    for_each = var.ec2_instance
    ami = each.value.ami_id
    instance_type = each.value.instance_type
    region = "us-east-1"
    subnet_id = each.value.subnet_id

    instance_market_options {
        market_type = "spot"
    }
    tags = {
        Name = each.key
    }
} 

