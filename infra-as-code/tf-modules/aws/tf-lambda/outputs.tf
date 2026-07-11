output "lambda_function_name" {
  value       = aws_lambda_function.docker_image_lambda.function_name
  description = "Lambda function name"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.docker_image_lambda.arn
  description = "Lambda function ARN"
}

output "lambda_function_invoke_arn" {
  value       = aws_lambda_function.docker_image_lambda.invoke_arn
  description = "Lambda function invoke ARN"
}

output "lambda_image_uri" {
  value       = aws_lambda_function.docker_image_lambda.image_uri
  description = "Image URI used by the Lambda"
}

output "ecr_repository_url" {
  value       = local.ecr_repository_url
  description = "ECR repository URL"
}

output "lambda_role_arn" {
  value       = aws_iam_role.lambda_role.arn
  description = "Lambda execution role ARN"
}
