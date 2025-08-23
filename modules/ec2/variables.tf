variable "ec2_instance" {
    type = map(object({
        instance_type = string
        ami_id = string
        subnet_id = string
        key_name = optional(string)
    }))
}
