data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "qnap_glacier_iam_user_policy_document" {
  # Global Glacier API permissions
  statement {
    effect = "Allow"

    actions = [
      "glacier:GetDataRetrievalPolicy",

      # "glacier:InitiateVaultLock",  # Not required for archive management
      # "glacier:AbortVaultLock",  # Not required for archive management
      # "glacier:CompleteVaultLock",  # Not required for archive management
      "glacier:ListVaults",
    ]

    resources = ["*"]
  }

  # Vault-Specific Glacier API permissions
  statement {
    effect = "Allow"

    actions = [
      "glacier:AbortMultipartUpload",

      # "glacier:AddTagsToVault",  # Not required for archive management
      "glacier:CompleteMultipartUpload",

      "glacier:CreateVault",             # Annoyingly, required by QNAP implementation
      "glacier:DeleteArchive",

      # "glacier:DeleteVault",  # Not required for archive management
      # "glacier:DeleteVaultAccessPolicy",  # Not required for archive management
      # "glacier:DeleteVaultNotifications",  # Not required for archive management
      "glacier:DescribeJob",

      "glacier:DescribeVault",
      "glacier:GetJobOutput",
      "glacier:GetVaultAccessPolicy",
      "glacier:GetVaultLock",
      "glacier:GetVaultNotifications",
      "glacier:InitiateJob",
      "glacier:InitiateMultipartUpload",
      "glacier:ListJobs",
      "glacier:ListMultipartUploads",
      "glacier:ListParts",
      "glacier:ListTagsForVault",

      # "glacier:RemoveTagsFromVault",  # Not required for archive management
      # "glacier:SetDataRetrievalPolicy",  # Not required for archive management
      # "glacier:SetVaultAccessPolicy",  # Not required for archive management
      # "glacier:SetVaultNotifications",  # Not required for archive management
      "glacier:UploadArchive",

      "glacier:UploadMultipartPart",
    ]

    resources = [
      "arn:aws:glacier:${var.region}:${data.aws_caller_identity.current.account_id}:vaults/${var.qnap_vault_name}",
    ]
  }
}

resource "aws_iam_policy" "qnap_glacier_iam_user_policy" {
  description = "Policy for QNAP Glacier User"
  name        = "QNAPGlacierIAMUserPolicy-${var.qnap_vault_name}"
  path        = "/automation/"
  policy      = "${data.aws_iam_policy_document.qnap_glacier_iam_user_policy_document.json}"
}

resource "aws_iam_user" "qnap_glacier_iam_user" {
  name = "${var.qnap_glacier_user_name == "" ? "${var.qnap_vault_name}-user" : var.qnap_glacier_user_name}"
  path = "/automation/"
}

resource "aws_iam_access_key" "qnap_glacier_iam_user_access_key" {
  user = "${aws_iam_user.qnap_glacier_iam_user.name}"
}

resource "aws_iam_user_policy_attachment" "qnap_glacier_iam_user_policy_attachment" {
  user       = "${aws_iam_user.qnap_glacier_iam_user.name}"
  policy_arn = "${aws_iam_policy.qnap_glacier_iam_user_policy.arn}"
}
