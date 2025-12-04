terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-vpc"
    },
    var.cluster_name != "" ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : {}
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-public-${var.availability_zones[count.index]}"
      Type = "public"
    },
    var.cluster_name != "" ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                    = "1"
    } : {}
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-private-${var.availability_zones[count.index]}"
      Type = "private"
    },
    var.cluster_name != "" ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1"
    } : {}
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.tags["Project"]}-${var.tags["Environment"]}-nat-eip" : "${var.tags["Project"]}-${var.tags["Environment"]}-nat-eip-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.tags["Project"]}-${var.tags["Environment"]}-nat" : "${var.tags["Project"]}-${var.tags["Environment"]}-nat-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-public-rt"
      Type = "public"
    }
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.tags["Project"]}-${var.tags["Environment"]}-private-rt" : "${var.tags["Project"]}-${var.tags["Environment"]}-private-rt-${var.availability_zones[count.index]}"
      Type = "private"
    }
  )
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

resource "aws_vpn_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-vgw"
    }
  )
}

locals {
  all_vpc_endpoint_services = {
    s3 = {
      service_name = "com.amazonaws.${var.region}.s3"
      service_type = "Gateway"
      route_tables = concat([aws_route_table.public.id], aws_route_table.private[*].id)
    }
    ecr_api = {
      service_name      = "com.amazonaws.${var.region}.ecr.api"
      service_type      = "Interface"
      subnet_ids        = aws_subnet.private[*].id
      security_group_ids = var.enable_vpc_endpoints ? [aws_security_group.vpc_endpoints[0].id] : []
    }
    ecr_dkr = {
      service_name      = "com.amazonaws.${var.region}.ecr.dkr"
      service_type      = "Interface"
      subnet_ids        = aws_subnet.private[*].id
      security_group_ids = var.enable_vpc_endpoints ? [aws_security_group.vpc_endpoints[0].id] : []
    }
    ec2 = {
      service_name      = "com.amazonaws.${var.region}.ec2"
      service_type      = "Interface"
      subnet_ids        = aws_subnet.private[*].id
      security_group_ids = var.enable_vpc_endpoints ? [aws_security_group.vpc_endpoints[0].id] : []
    }
    ec2messages = {
      service_name      = "com.amazonaws.${var.region}.ec2messages"
      service_type      = "Interface"
      subnet_ids        = aws_subnet.private[*].id
      security_group_ids = var.enable_vpc_endpoints ? [aws_security_group.vpc_endpoints[0].id] : []
    }
    sts = {
      service_name      = "com.amazonaws.${var.region}.sts"
      service_type      = "Interface"
      subnet_ids        = aws_subnet.private[*].id
      security_group_ids = var.enable_vpc_endpoints ? [aws_security_group.vpc_endpoints[0].id] : []
    }
    logs = {
      service_name      = "com.amazonaws.${var.region}.logs"
      service_type      = "Interface"
      subnet_ids        = aws_subnet.private[*].id
      security_group_ids = var.enable_vpc_endpoints ? [aws_security_group.vpc_endpoints[0].id] : []
    }
  }

  selected_vpc_endpoints = !var.enable_vpc_endpoints ? [] : (
    length(var.vpc_endpoints) == 0 ? keys(local.all_vpc_endpoint_services) : var.vpc_endpoints
  )

  vpc_endpoints_to_create = {
    for k in local.selected_vpc_endpoints : k => local.all_vpc_endpoint_services[k]
  }
}

resource "aws_security_group" "vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  name_prefix = "${var.tags["Project"]}-${var.tags["Environment"]}-vpce-"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-vpce-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_endpoint" "this" {
  for_each = local.vpc_endpoints_to_create

  vpc_id             = aws_vpc.main.id
  service_name       = each.value.service_name
  vpc_endpoint_type  = each.value.service_type

  route_table_ids    = each.value.service_type == "Gateway" ? each.value.route_tables : null
  subnet_ids         = each.value.service_type == "Interface" ? each.value.subnet_ids : null
  security_group_ids = each.value.service_type == "Interface" ? each.value.security_group_ids : null

  private_dns_enabled = each.value.service_type == "Interface" ? true : null

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-vpce-${each.key}"
    }
  )
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/flow-logs/${var.tags["Project"]}-${var.tags["Environment"]}"
  retention_in_days = var.flow_logs_retention_days

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [name]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-vpc-flow-logs"
    }
  )
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.tags["Project"]}-${var.tags["Environment"]}-vpc-flow-logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-vpc-flow-logs-role"
    }
  )
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.main.id
  traffic_type    = var.flow_logs_traffic_type
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn

  # Explicit dependencies to ensure proper destroy order
  # During destroy: flow log must be deleted BEFORE log group and IAM resources
  depends_on = [
    aws_cloudwatch_log_group.flow_logs,
    aws_iam_role.flow_logs,
    aws_iam_role_policy.flow_logs
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Project"]}-${var.tags["Environment"]}-vpc-flow-logs"
    }
  )
}
