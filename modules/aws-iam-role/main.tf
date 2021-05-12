resource "aws_iam_role" "web_app_role" {
  name = "webapp_role"
  path = "/"
  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name = "Ec2CloudWatchAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["cloudwatch:PutMetricData",
            "cloudwatch:PutMetricAlarm",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "ec2:DescribeTags",
            "ec2:DescribeInstances"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  inline_policy {
    name = "Ec2Route53Access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["route53:CreateHostedZone",
            "route53:AssociateVPCWithHostedZone",
            "route53:ChangeResourceRecordSets",
            "route53:Get*",
            "route53:List*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  inline_policy {
    name = "APIGatewayAccess"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["apigateway:GET"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  tags = {
    tag-key = "tag-value"
  }
}
