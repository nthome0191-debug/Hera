locals {
  subnet_logic = flatten([
    for cluster_idx, cluster in var.clusters : [
      for az_idx, az in cluster.azs : {
        id          = "${cluster.name}-${az}"
        name        = cluster.name
        az          = az
        az_index    = az_idx
        private_num = (cluster_idx * 4) + az_idx
        public_num  = 100 + (cluster_idx * 4) + az_idx
      }
    ]
  ])
}

resource "aws_subnet" "private" {
  for_each          = { for s in local.subnet_logic : s.id => s }
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value.private_num) # Result: /20

  tags = {
    Name                                          = "${each.value.id}-private"
    "kubernetes.io/cluster/${each.value.name}"    = "owned"
    "kubernetes.io/role/internal-elb"             = "1"
    az_index = each.value.az_index
  }
}

resource "aws_subnet" "public" {
  for_each          = { for s in local.subnet_logic : s.id => s }
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.public_num) # Result: /24

  tags = {
    Name                                          = "${each.value.id}-public"
    "kubernetes.io/cluster/${each.value.name}"    = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }
}