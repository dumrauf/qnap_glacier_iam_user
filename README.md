# QNAP Glacier IAM User

This repository contains a Terraform module that creates an IAM user, including access keys, that can then be used in the [QNAP Glacier](https://www.qnap.com/en/how-to/tutorial/article/full-technical-qnap-cloudbackup-application-note) app.

> For further information, see the corresponding article on [https://www.how-hard-can-it.be/qnap-glacier-iam-user/](https://www.how-hard-can-it.be/qnap-glacier-iam-user/).


## You Have

Before you can use the Terraform module in this repository out of the box, you need

 - an [AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html)
 - a [Terraform](https://www.terraform.io/intro/getting-started/install.html) CLI


## You Want

After running the Terraform module in this repository you get an _IAM user with corresponding access key and secret access_ key that can be used in the QNAP Glacier app.
Here, the IAM user is _only permitted to work with archives_ in a given AWS Glacier Vault. Modifying or deleting the vault is not permitted.

## Setup

The input variables for the module are defined in [settings/example.tfvars](settings/example.tfvars) to be
```hcl
region = "<your-region>"

shared_credentials_file = "/path/to/.aws/credentials"

profile = "<your-profile>"

qnap_vault_name = "<your-QNAP-Glacier-vault>"
```
Here, you need to replace the example values with your settings. Note that you also need to update the `qnap_vault_name` to the name of an AWS Glacier Vault that does not exist. Moreover, the current value is _not a valid input_

<div class="alert alert-info">
Make sure that the `qnap_vault_name` refers to an AWS Glacier Vault which _does not exist_. The QNAP Glacier app assumes that it can create the given AWS Glacier vault.
</div>


## Execution

Initialise Terraform by running
```
terraform init
```
As a best practice, create a new workspace by running
```
terraform workspace new example
```
The QNAP Glacier IAM user can be planned by running
```
terraform plan -var-file=settings/example.tfvars
```
and created by running
```
terraform apply -var-file=settings/example.tfvars
```


## Outputs

The module has two outputs, namely `qnap_glacier_user_access_key` and `qnap_glacier_user_secret_access_key` which are the access key and secret access key of the newly created IAM user.

The access key and secret access key are intended to be used in the QNAP Glacier app as is.


## Deletion

The QNAP Glacier IAM user can be deleted by running
```
terraform destroy -var-file=settings/example.tfvars
```


## FAQs


### Why Do I Have to Specify the AWS Glacier Vault but then it does not get Created by the Terraform Module?

The QNAP Glacier app expects to be able to create the AWS Glacier vault to be used. This makes sense when considering that AWS Glacier vault inventories are generated approximately once a day. It's the safest way to create a brand new AWS Glacier Vault for the QNAP Glacier app.

However, this limits the ability to leverage other functions of AWS Glacier vaults, such as notifications via SQS queues. 


### What's the IAM Policy Being Used for the QNAP Glacier IAM User?

The IAM policy being used for the QNAP Glacier IAM User is
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "glacier:ListVaults",
                "glacier:GetDataRetrievalPolicy"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "glacier:UploadMultipartPart",
                "glacier:UploadArchive",
                "glacier:ListTagsForVault",
                "glacier:ListParts",
                "glacier:ListMultipartUploads",
                "glacier:ListJobs",
                "glacier:InitiateMultipartUpload",
                "glacier:InitiateJob",
                "glacier:GetVaultNotifications",
                "glacier:GetVaultLock",
                "glacier:GetVaultAccessPolicy",
                "glacier:GetJobOutput",
                "glacier:DescribeVault",
                "glacier:DescribeJob",
                "glacier:DeleteArchive",
                "glacier:CreateVault",
                "glacier:CompleteMultipartUpload",
                "glacier:AbortMultipartUpload"
            ],
            "Resource": "arn:aws:glacier:<your-region>:<your-account>:vaults/<your-vault>"
        }
    ]
}
```
Here, the value of `Resource` will be tailored to your region, account, and vault.


### Why's the `glacier:CreateVault` Permission Granted in the IAM Policy for the QNAP Glacier IAM User?

The QNAP Glacier app expects to be able to create the AWS Glacier vault to be used. This makes sense when considering that AWS Glacier vault inventories are generated approximately once a day. It's the safest way to create a brand new AWS Glacier Vault for the QNAP Glacier app.


### Can the IAM User Create Other AWS Glacier Vaults?

No. The `glacier:CreateVault` permission is only granted on the AWS Glacier vault provided in the input variables.


### Can the IAM User be Used for Other Vaults in QNAP Glacier?

No. The IAM user is specifically designed to work with a dedicated AWS Glacier vault. This limits the blast radius in case something goes wrong.


### How do I Create Another IAM User for Another Vault in QNAP Glacier?

Simply create another Terraform workspace by running
```
terraform workspace new second-example
```
and then plan and apply the Terraform module again.
