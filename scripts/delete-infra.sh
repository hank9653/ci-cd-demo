#!/usr/bin/env bash
set -euo pipefail

function print_function_name(){
    echo "$(tput bold;tput setaf 2 ) === ${FUNCNAME[1]} === $(tput sgr0)"
}

function ecs_service_delete() {
    print_function_name

    aws cloudformation delete-stack --stack-name web
    aws cloudformation wait stack-delete-complete --stack-name web
}
function ecs_cluster_delete() {
    print_function_name

    aws cloudformation delete-stack --stack-name web-cluster
    aws cloudformation wait stack-delete-complete --stack-name web-cluster
}

function iam_delete() {
    print_function_name

    aws cloudformation delete-stack --stack-name iam
    aws cloudformation wait stack-delete-complete --stack-name CAPABILITY_IAM
}

function vpc_delete() {
    print_function_name

    aws cloudformation delete-stack --stack-name vpc
    aws cloudformation wait stack-delete-complete --stack-name vpc
}

function ecr_delete() {
    print_function_name

    aws ecr delete-repository --force --repository-name repo
}

# Main
function main() {
    ecs_service_delete
    ecs_cluster_delete
    iam_delete
    vpc_delete
    ecr_delete
}

main