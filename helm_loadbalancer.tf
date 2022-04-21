
provider "helm" {
  
  kubernetes {
   host                   = data.aws_eks_cluster.demo.endpoint
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo.certificate_authority.0.data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
      command     = "aws"
 }
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  #depends_on = [null_resource.post-policy,  aws_iam_role.aws-node]
  depends_on = [null_resource.post-policy]
  name       = "aws-load-balancer-controller"
  

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace = "kube-system"

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.demo.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-node"
  }

  set {
    name  = "image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/amazon/aws-load-balancer-controller",var.aws_region)
  }

  set {
    name  = "image.tag"
    value = "v2.4.0"
  }
  set {
      name = "serviceAccount\\.server\\.annotations\\.eks\\.amazonaws\\.com/role-arn"
      value= "arn:aws:iam::${var.account_id}:role/aws-node"  
  }

}