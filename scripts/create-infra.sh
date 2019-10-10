#!/usr/bin/env bash
set -euo pipefail

function print_function_name(){
    echo "$(tput bold;tput setaf 2 ) === ${FUNCNAME[1]} === $(tput sgr0)"
}

function ecr_create() {
    print_function_name

    aws ecr create-repository --repository-name repo
}

function ecr_login() {
    print_function_name

    eval $( aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION} )
}

function docker_build_tag_push() {
    print_function_name

    docker build -t node-sample .
    IMAGE_REPO=$(aws ecr describe-repositories --repository-names repo --query 'repositories[0].repositoryUri' --output text)
    docker tag node-sample:latest $IMAGE_REPO:latest
    docker push $IMAGE_REPO:latest
}

function vpc_create() {
    print_function_name

    aws cloudformation create-stack --template-body file://./script/infra/vpc.yml --stack-name vpc
    aws cloudformation wait stack-create-complete --stack-name vpc
}
function iam_create() {
    print_function_name

    aws cloudformation create-stack --template-body file://./script/infra/iam.yml --stack-name iam --capabilities CAPABILITY_IAM
}
function ecs_cluster_create() {
    print_function_name

    aws cloudformation create-stack --template-body file://./script/infra/web-cluster.yml --stack-name web-cluster
    aws cloudformation wait stack-create-complete --stack-name web-cluster
}

function ecs_service_create() {
    print_function_name

    # Edit the api.yml to update Image tag/URL under Task > ContainerDefinitions and,
    aws cloudformation create-stack --template-body file://./script/infra/web.yml --stack-name web
    aws cloudformation wait stack-create-complete --stack-name web
}

function url() {
    print_function_name

    aws elbv2 describe-load-balancers --names ecs-services | jq -r '.LoadBalancers[0].DNSName'
}

# Main
function main() {
    ecr_create
    ecr_login
    docker_build_tag_push
    iam_create
    vpc_create
    ecs_cluster_create
    ecs_service_create
    url
}

main