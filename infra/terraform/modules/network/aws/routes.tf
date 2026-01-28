resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.vpc_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = local.nat_gateway_count
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }
  tags = { Name = "${var.vpc_name}-private-rt-${count.index}" }
}

resource "aws_route_table_association" "private" {
  for_each  = aws_subnet.private
  subnet_id = each.value.id
  
  # Logic: If 1 NAT, all associate with that 1 RT. 
  # If 3 NATs, we associate by AZ index to keep traffic "local" to the AZ.
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[tonumber(each.value.tags["az_index"])].id
}