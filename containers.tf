/*# ==========================================================
# 1. ECR (Elastic Container Registry) - To store Docker Images
# ==========================================================
resource "aws_ecr_repository" "docker_repo" {
  name                 = "vikas-app-registry"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # Automatically scans images for vulnerabilities
  }
}

# ==========================================================
# 2. IAM ROLE FOR EKS (Elastic Kubernetes Service)
# Gives the Kubernetes control plane permission to manage AWS resources
# ==========================================================
resource "aws_iam_role" "eks_cluster_role" {
  name = "vikas-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# Attach the standard AWS EKS Cluster policy to the role above
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# ==========================================================
# 3. EKS (Elastic Kubernetes Service) Cluster Setup
# ==========================================================
# containers.tf

resource "aws_eks_cluster" "k8s_cluster" {
  name     = "vikas-devops-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # Dynamically passing both high-availability subnets from your VPC layer module
    subnet_ids = [
      module.my_vpc_layer.subnet_id,  # Points to ap-south-1a
      module.my_vpc_layer.subnet_id_b # Points to ap-south-1b
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}
*/