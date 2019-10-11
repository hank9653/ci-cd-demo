#!/usr/bin/env bash
set -euo pipefail

# Usage: ./deploy_app.sh <CLUSTER NAME> <SERVICE NAME> <TASK FAMILY>
CLUSTER=$1
SERVICE=$2
TASK_FAMILY=$3

function print_function_name(){
    echo "$(tput bold;tput setaf 2 ) === ${FUNCNAME[1]} === $(tput sgr0)"
}

function install_tools() {
    print_function_name

    pip install -q --user awscli
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

function replace_var_in_taskdefinition() {
    print_function_name

    # Get the current task definition
    TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "${TASK_FAMILY}")
   
    # Use 'jq' (json processor) to read current container and task properties
    CONTAINER_DEFINITIONS=$(echo "$TASK_DEFINITION" | jq '. | .taskDefinition.containerDefinitions')
    TASK_EXEC_ROLE_ARN=$(echo "$TASK_DEFINITION" | jq '. | .taskDefinition.executionRoleArn | tostring' | cut -d'/' -f2 | sed -e 's/"$//')
    TASK_CPU=$(echo "$TASK_DEFINITION" | jq '. | .taskDefinition.cpu | tonumber')
    TASK_MEMORY=$(echo "$TASK_DEFINITION" | jq '. | .taskDefinition.memory | tonumber')
}

function ecs_register_task_definition() {
    print_function_name

    # Register new task. No change to container definition.
    # aws ecs register-task-definition --family ${TASK_FAMILY} --requires-compatibilities FARGATE --network-mode awsvpc --task-role-arn $TASK_EXEC_ROLE_ARN --execution-role-arn $TASK_EXEC_ROLE_ARN --cpu ${TASK_CPU} --memory ${TASK_MEMORY} --container-definitions "${CONTAINER_DEFINITIONS}"

    local outputs
    outputs=$(aws ecs register-task-definition \
        --family ${TASK_FAMILY} \
        --requires-compatibilities FARGATE \
        --network-mode awsvpc \
        --task-role-arn $TASK_EXEC_ROLE_ARN \
        --execution-role-arn $TASK_EXEC_ROLE_ARN \
        --cpu ${TASK_CPU} \
        --memory ${TASK_MEMORY} \
        --container-definitions "${CONTAINER_DEFINITIONS}" )
    echo $( echo $outputs | jq -r '.taskDefinition|"Registered taskdefinition : "+.family+":"+(.revision|tostring)' )
}

function ecs_update_service() {
    print_function_name

    # Update service to use new task defn - This should pick the new image for the new revision of task defn
    # aws ecs update-service --cluster "${CLUSTER}" --service "${SERVICE}"  --task-definition "${TASK_FAMILY}"

    # Update service with new version task definition
    local outputs
    outputs=$( aws ecs update-service \
        --cluster "${CLUSTER}" \
        --service "${SERVICE}" \
        --task-definition "${TASK_FAMILY}" )
    echo $( echo $outputs | jq -r '.service.deployments' ) | jq -r '.'
}

function ecs_wait_services_stable() {
    print_function_name

    aws ecs wait services-stable --cluster  ${CLUSTER} --services "${SERVICE}"
}

# Main
function main() {
    install_tools
    ecr_login
    docker_build_tag_push
    replace_var_in_taskdefinition
    ecs_register_task_definition
    ecs_update_service
    ecs_wait_services_stable
}

main
