# Docker on Amazon ECS using AWS CloudFormation & CLI

Devteds [Episode #9](https://devteds.com/episodes/9-docker-on-amazon-ecs-using-cloudformation)

Create and run docker container on Amazon ECS using CloudFormation and CLI.

- Containerize a simple REST API application
- Use AWS CLI to create Amazon ECR repository
- Build docker image and push to ECR
- CloudFormation stack to create VPC, Subnets, InternetGateway etc
- CloudFormation stack to create IAM role
- CloudFormation stack to create ECS Cluster, Loadbalancer & Listener, Security groups etc
- CloudFormation stack to deploy docker container

[Episode video link](https://youtu.be/Gr2yTSsVSqg)

[![Episode Video Link](https://i.ytimg.com/vi/Gr2yTSsVSqg/hqdefault.jpg)](https://youtu.be/Gr2yTSsVSqg)

Visit https://devteds.com to watch all the episodes

## Step

```
$ sh ./script/create-infra.sh
$ sh ./script/delete-infra.sh
$ sh ./script/depoly-app.sh
```