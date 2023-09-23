resource "aws_kms_key" "my_kms_key" {
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
}



resource "aws_iam_policy" "kms_key_policy" {
  name        = "MyKmsKeyPolicy"
  description = "Policy for KMS key usage"

  # Specify the policy document here, which defines the permissions.
  # You can use the JSON format for the policy document.
  # For example:

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
    Statement = [
      {
        Sid       = "Enable IAM User Permissions",
        Effect    = "Allow",
        Principal = {
          AWS = var.kms_admin_arn
        },
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource  = aws_kms_key.my_kms_key.arn,
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Sid       = "Allow administration of the key",
        Effect    = "Allow",
        Principal = {
          AWS = var.kms_admin_arn
        },
        Action    = [
          "kms:ListKeys",
          "kms:ListAliases",
          "kms:GetKeyPolicy",
          "kms:PutKeyPolicy"
        ],
        Resource  = aws_kms_key.my_kms_key.arn
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "kms_key_policy_attachment" {
  name       = "kms_key_policy_attachment"
  policy_arn = aws_iam_policy.kms_key_policy.arn
  #user       = aws_iam_user.example_user.name
  users      = []
  roles      = []
}


output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.my_kms_key.arn
}



