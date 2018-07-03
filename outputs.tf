output "qnap_glacier_user_access_key" {
  value = "${aws_iam_access_key.qnap_glacier_iam_user_access_key.id}"
}

output "qnap_glacier_user_secret_access_key" {
  value = "${aws_iam_access_key.qnap_glacier_iam_user_access_key.secret}"
}
