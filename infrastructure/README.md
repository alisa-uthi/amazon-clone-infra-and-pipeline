# Amazon Clone Infrastructure on AWS

---

## Step to Create/Update Kubernetes Cluster on AWS with kOps

1. Go to `infrastructure/script`

2. Run below command
```
$ ./regen-cluster.sh -e dev --cluster-only
```

---

## Security

Currently AWS RDS and DynamoDB allow access from all pods in worker nodes. If possible, deploy kubernetes cluster on AWS EKS and use IRSA (IAM Roles for ServiceAccounts) to restrict Pod access to AWS Resources.