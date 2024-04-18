# python-app
![alt text](https://lucid.app/publicSegments/view/85946820-5170-4cda-8fc4-585451ec611f/image.png)

This repo deploys a python application in a kubernetes cluster.

It utilizes a Jenkins pipeline to build a docker image for the application, pushes the image to ECR and deploys the image on EKS

### Tools Used
- Jenkins
- Docker
- Terraform
- Kubernetes
- Git

### AWS Resources Used
- Amazon EC2 Compute Service 
- Amazon Elastic Kubernetes Service (Amazon EKS) 
- Amazon Simple Storage Service (Amazon S3)
- Amazon Route53
- Elastic Load Balancing (ELB)
- AWS Certificate Manager
