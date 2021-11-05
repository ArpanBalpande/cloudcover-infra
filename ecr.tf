resource "aws_ecr_repository" "ecr" {
  name                 = "my-cool-application"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}