
resource "terraform_data" "wait_for_eni_cleanup" {
  input = {
    cluster_sg_id = aws_security_group.cluster.id
    node_sg_id    = aws_security_group.node.id
    region        = var.region
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Hera Cleanup: Waiting for ENIs associated with security groups to be released..."

      for i in $(seq 1 60); do
        enis=$(aws ec2 describe-network-interfaces \
          --region ${self.input.region} \
          --filters "Name=group-id,Values=${self.input.cluster_sg_id},${self.input.node_sg_id}" \
          --query 'length(NetworkInterfaces)' \
          --output text 2>/dev/null || echo "0")

        if [ "$enis" = "0" ]; then
          echo "All ENIs cleaned up successfully."
          exit 0
        fi

        echo "Waiting for $enis ENIs to be deleted... (attempt $i/60)"
        sleep 5
      done
    EOT
  }

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_cluster.main
  ]
}

resource "null_resource" "update_kubeconfig" {
  depends_on = [aws_eks_cluster.main]

  triggers = {
    cluster_name = aws_eks_cluster.main.name
  }

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig \
        --region ${var.region} \
        --name ${aws_eks_cluster.main.name} \
        ${var.kubeconfig_context_name != "" ? "--alias ${var.kubeconfig_context_name}" : ""}
    EOT
  }
}