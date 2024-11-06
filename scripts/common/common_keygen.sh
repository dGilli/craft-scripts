#!/bin/bash

# Common SSH-Keygen
#
# Shared script to set various SSH-Keygen-related variables
#
# @author    Dennis Gilli <me@dennisgilli.com>
# @copyright Copyright (c) 2024 Dennis Gilli
# @link      https://dennisgilli.com/
# @license   MIT

SSH_KEYGEN_STRENGTH_ARGS=""
SSH_KEYGEN_STRENGTH_ARGS+="-t ed25519 "

SSH_KEYGEN_ARGS=""
SSH_KEYGEN_ARGS+="-C azure-pipelines "
SSH_KEYGEN_ARGS+="-f azure-pipelines "
SSH_KEYGEN_ARGS+="-N '' "
SSH_KEYGEN_ARGS+="${SSH_KEYGEN_STRENGTH_ARGS} "

function generate_ssh_keys() {
    $LOCAL_SHH_KEYGEN_CMD "${SSH_KEYGEN_ARGS}"

    # Read the contents of the private and public keys into local variables
    local private_key
    local public_key
    private_key=$(<"azure-pipelines")
    public_key=$(<"azure-pipelines.pub")

    # Clean up the key files and echo the keys as a pair
    rm -f "azure-pipelines" "azure-pipelines.pub"
    echo "$private_key|$public_key"
}
