#!/bin/bash

# Common Azure
#
# Shared script to set various Azure-related variables
#
# @author    Dennis Gilli <me@dennisgilli.com>
# @copyright Copyright (c) 2024 Dennis Gilli
# @link      https://dennisgilli.com/
# @license   MIT

AZURE_DEVOPS_BASEURL="https://dev.azure.com"

# Path to the JSON configuration file for setting up the Azure service connection
AZURE_SERVICE_CONN_CONF_PATH=""
AZURE_SERVICE_CONN_CONF_PATH+="${LOCAL_CONF_PATH}/"
AZURE_SERVICE_CONN_CONF_PATH+="${CICD_SSH_CONF_FILE}"

# Azure CLI command to create a service endpoint in Azure DevOps
AZURE_SERVICE_CONN_CREATE_CMD="devops service-endpoint create"

# Argument to define service endpoint configuration as file path
AZURE_SERVICE_CONN_CREATE_FROM_FILE_ARGS=""
AZURE_SERVICE_CONN_CREATE_FROM_FILE_ARGS+="--service-endpoint-configuration=${AZURE_SERVICE_CONN_CONF_PATH} "

# Argument to take service endpoint configuration from the pipe
AZURE_SERVICE_CONN_CREATE_FROM_PIPE_ARGS=""
AZURE_SERVICE_CONN_CREATE_FROM_PIPE_ARGS+="--service-endpoint-configuration=@- "

# Arguments to create a service endpoint
AZURE_SERVICE_CONN_CREATE_ARGS=""
AZURE_SERVICE_CONN_CREATE_ARGS+="--project=${CICD_PROJECT_ID} "
AZURE_SERVICE_CONN_CREATE_ARGS+=$AZURE_SERVICE_CONN_CREATE_FROM_PIPE_ARGS

AZURE_SERVICE_CONN_SETTINGS_URL=""
AZURE_SERVICE_CONN_SETTINGS_URL=+"${AZURE_DEVOPS_BASEURL}/${CICD_PROJECT_ID}/_settings/adminservices"
AZURE_SERVICE_CONN_SETTINGS_URL=+"?resourceId=$SERVICE_ID"
