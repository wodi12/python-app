locals {
  tags = {
    created-by = "terraform"
    env        = var.cluster_name
  }
}