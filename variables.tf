variable "region" {
  description = "The AWS region to use (currently only 'us-east-1', 'us-west-1', 'us-west-2', 'eu-west-1', 'eu-central-1', 'ap-southeast-2', and 'ap-northeast-1' are supported by QNAP Glacier as of 7/2018)"
  default     = "eu-west-1"
}

variable "shared_credentials_file" {
  description = "The location of the AWS shared credentials file (e.g. ~dominic/.aws/credentials)"
}

variable "profile" {
  description = "The profile to use"
}

variable "qnap_vault_name" {
  description = "The name of the QNAP Glacier vault"
  default     = "QNAP-Glacier-Vault"
}

variable "qnap_glacier_user_name" {
  description = "The name of the QNAP Glacier user to create (leave blank to set automatically) "
  default     = ""
}
