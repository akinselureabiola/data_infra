resource "aws_iam_user" "airflow" {
  name = "airflow-local"
}

data "aws_iam_policy_document" "airflow_policy_doc" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::staging-olist",
      "arn:aws:s3:::staging-olist/*"
    ]
  }
}

resource "aws_iam_policy" "airflow_policy" {
  name        = "airflow-policy"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.airflow_policy_doc.json
}

resource "aws_iam_user_policy_attachment" "airflow_policy_attachment" {
  user       = aws_iam_user.airflow.name
  policy_arn = aws_iam_policy.airflow_policy.arn
}

resource "aws_iam_access_key" "airflow_access_secret_key" {
  user = aws_iam_user.airflow.name
}

resource "aws_ssm_parameter" "airflow_access_key" {
  name  = "/airflow-local/access-key"
  type  = "String"
  value = aws_iam_access_key.airflow_access_secret_key.id
}

resource "aws_ssm_parameter" "airflow_secret_key" {
  name  = "/airflow-local/secret-key"
  type  = "String"
  value = aws_iam_access_key.airflow_access_secret_key.secret
}
