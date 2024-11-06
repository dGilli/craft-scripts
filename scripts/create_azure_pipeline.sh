#!/bin/bash

# Pull Database
#
# Pull remote database down from a remote and restore it to to local
#
# @author    Dennis Gilli <me@dennisgilli.com>
# @copyright Copyright (c) 2024 Dennis Gilli
# @link      https://dennisgilli.com/
# @license   MIT

# Docket:
# this pipeline uses azure cli to create a new deployment pipeline capable of deploying to staging and production.
# it will follow a few steps to setup a new ssh service connection to the production server.
# then it will create a new pipeline with the azure-pipelines.yml in this project.
# on the server it has to setup .env files and possibly some asset directories
# finally the pipeline is run to staging to test it out

# Get the directory of the currently executing script
DIR="$(dirname "${BASH_SOURCE[0]}")"

# Include files
INCLUDE_FILES=(
            "common/defaults.sh"
            ".env.sh"
            "common/common_env.sh"
            "common/common_azure.sh"
            "common/common_keygen.sh"
            )
for INCLUDE_FILE in "${INCLUDE_FILES[@]}"
do
    if [[ ! -f "${DIR}/${INCLUDE_FILE}" ]] ; then
        echo "File ${DIR}/${INCLUDE_FILE} is missing, aborting."
        exit 1
    fi
    source "${DIR}/${INCLUDE_FILE}"
done

# Functions
function create_azure_service_conn() {
    # Create a SSH service connection on Azure Devops
    az "${AZURE_SERVICE_CONN_CREATE_CMD}" "${AZURE_SERVICE_CONN_CREATE_ARGS}"
}
function remote_key_find_ssh() {
    ssh $REMOTE_SSH_LOGIN -p $REMOTE_SSH_PORT "$REMOTE_KEY_FIND_CMD"
}
function remote_key_write_ssh() {
    ssh $REMOTE_SSH_LOGIN -p $REMOTE_SSH_PORT "$REMOTE_KEY_WRITE_CMD"
}
function remote_key_overwrite_ssh() {
    ssh $REMOTE_SSH_LOGIN -p $REMOTE_SSH_PORT "$REMOTE_KEY_DELETE_CMD"
    remote_key_write_ssh
}

echo "*** Creating new Azure service connection from ${AZURE_SERVICE_CONFIG_PATH}"
SERVICE_CONNECTION=$(create_azure_service_conn)
SERVICE_ID=$(echo "$SERVICE_CONNECTION" | jq -r '.id')

IFS='|' read -r PRIVATE_KEY PUBLIC_KEY <<< "$(generate_ssh_keys)"

echo "*** Copying the private key to the clipboard, you have to paste it into Azure DevOps manually..."
echo "$PRIVATE_KEY" | $COPY_CMD
echo -e "*** Opening Azure DevOps for manual key setup\nPress Enter to proceed..."; read -r
$OPEN_CMD "${AZURE_SERVICE_CONN_SETTINGS_URL}?resourceId=${SERVICE_ID}"

# Clear private key from clipboard:
echo -n | $COPY_CMD

REMOTE_KEY_FIND_CMD="grep 'azure-pipelines' ~/.ssh/authorized_keys || echo 'not_found'"
REMOTE_KEY_WRITE_CMD="echo '$PUBLIC_KEY' >> ~/.ssh/authorized_keys"
REMOTE_KEY_DELETE_CMD="sed -i '' '/azure-pipelines/d' ~/.ssh/authorized_keys"

echo "*** Adding the public key to the remote server..."
if [[ "$(remote_key_find_ssh)" != "not_found" ]]; then
    echo -e "A public key with the name 'azure-pipelines' already exists on the server.\nDo you want to overwrite it? (y/n):"; read -r OVERWRITE

    if [[ "$OVERWRITE" != "y" ]]; then
        continue
    else
        echo "*** Overwriting the existing public key..."
        remote_key_overwrite_ssh
        remote_key_write_ssh
    fi
else
    remote_key_write_ssh
fi

# UNIMPLEMENTED...
echo -e "*** Create new azure pipeline for Project $PROJECT_NAME...\nPress Enter to continue..."; read -r
echo -e "Run the newly created pipeline to staging and open the run...\nPress Enter to continue..."; read -r

exit 0
