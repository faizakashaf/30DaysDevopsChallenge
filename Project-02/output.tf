locals {
  confirmation_instructions = <<EOT
  Resources have been successfully created!

  1. Check your email inbox to confirm the subscription to the SNS topic.
  2. The Lambda function will fetch NBA updates and publish them to the SNS topic.
  3. Ensure that the EventBridge rule triggers the Lambda function every minute.

  Happy Terraforming!
  EOT
}

output "summary_message" {
  value       = local.confirmation_instructions
  description = "A summary of next steps after resource creation"
}

