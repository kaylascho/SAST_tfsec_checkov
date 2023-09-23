variable "kms_key_description" {
  type        = string
  description = "Description of the KMS key"
  default     = "My KMS Key Description"  # Set your desired default value
}

variable "kms_deletion_window_in_days" {
  type        = number
  description = "Deletion window in days for the KMS key"
  default     = 10  # Set your desired default value
}

variable "kms_enable_key_rotation" {
  type        = bool
  description = "Enable key rotation for the KMS key"
  default     = true  # Set your desired default value
}

variable "kms_admin_arn" {
  type        = string
  description = "ARN of the key administrator"
  default     = "arn:aws:iam::986114105941:root"  # Set your desired default value
}
