# --- NAT Gateway Logic ---

locals {
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count
  tags  = { Name = "${var.vpc_name}-nat-eip-${count.index}" }
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  
  # We always place NATs in the first available public subnets
  # Using the first cluster's public subnets as the host
  subnet_id     = values(aws_subnet.public)[count.index].id

  tags = { Name = "${var.vpc_name}-nat-${count.index}" }

  depends_on = [aws_internet_gateway.this]
}