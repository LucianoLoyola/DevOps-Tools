#!/bin/bash
#
# Script to add a VPC peering route to all route tables associated
# with "Private" subnets in a specified VPC.
#

# --- Configuration Parameters ---
VPC_ID="vpc-x"
REGION="us-east-1"
DEST_CIDR="x.x.x.x/16"
PEERING_ID="pcx-x"
NAME_FILTER="*Private*"

# --- Script Setup ---
# Exit on undefined variable, fail on pipe errors
set -uo pipefail

# Common AWS CLI arguments for region and output
AWS_ARGS="--region ${REGION} --output json"

echo "--- Starting Route Addition Script ---"
echo "VPC:         ${VPC_ID}"
echo "Region:      ${REGION}"
echo "Destination: ${DEST_CIDR}"
echo "Peering ID:  ${PEERING_ID}"
echo "Subnet Name: ${NAME_FILTER}"
echo "--------------------------------------"

# --- 1. Find the VPC's Main Route Table ID ---
echo "1. Finding Main Route Table ID for ${VPC_ID}..."
MAIN_RTB_ID=$(aws ec2 describe-route-tables $AWS_ARGS \
  --filters "Name=vpc-id,Values=${VPC_ID}" "Name=association.main,Values=true" \
  | jq -r '.RouteTables[0].RouteTableId')

if [ -z "$MAIN_RTB_ID" ] || [ "$MAIN_RTB_ID" == "null" ]; then
  echo "Error: Could not find main route table for ${VPC_ID}." >&2
  exit 1
fi
echo "   Found Main Route Table: ${MAIN_RTB_ID}"


# --- 2. Find all 'Private' subnet IDs ---
echo "2. Finding subnets with name filter '${NAME_FILTER}'..."
# Read the list of subnet IDs into a bash array
mapfile -t PRIVATE_SUBNET_IDS < <(aws ec2 describe-subnets $AWS_ARGS \
  --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${NAME_FILTER}" \
  | jq -r '.Subnets[].SubnetId')

if [ ${#PRIVATE_SUBNET_IDS[@]} -eq 0 ]; then
  echo "   No subnets found with name filter '${NAME_FILTER}'. Exiting."
  exit 0
fi
echo "   Found ${#PRIVATE_SUBNET_IDS[@]} matching subnets."


# --- 3. Get all explicit route table associations ---
echo "3. Fetching explicit route table associations..."
# Creates a single JSON object like: {"subnet-id-1": "rtb-id-A", "subnet-id-2": "rtb-id-B"}
# This is much more efficient than calling `describe-route-tables` per subnet.
EXPLICIT_ASSOCIATIONS=$(aws ec2 describe-route-tables $AWS_ARGS \
  --filters "Name=vpc-id,Values=${VPC_ID}" \
  | jq -r '[.RouteTables[].Associations[] | select(.SubnetId)] | map({(.SubnetId): .RouteTableId}) | add')

if [ -z "$EXPLICIT_ASSOCIATIONS" ]; then
    EXPLICIT_ASSOCIATIONS="{}" # Ensure it's a valid empty JSON object
fi


# --- 4. Create a list of unique route table IDs to update ---
echo "4. Determining target route tables..."
TARGET_RTB_IDS_LIST="" # We'll build a newline-separated string first

for subnet_id in "${PRIVATE_SUBNET_IDS[@]}"; do
  # Use jq to query our association map
  explicit_rtb=$(echo "${EXPLICIT_ASSOCIATIONS}" | jq -r --arg SUBNET_ID "$subnet_id" '.[$SUBNET_ID]')

  if [ "$explicit_rtb" != "null" ] && [ -n "$explicit_rtb" ]; then
    # This subnet has an explicit association
    TARGET_RTB_IDS_LIST+="${explicit_rtb}\n"
  else
    # This subnet uses the main route table
    TARGET_RTB_IDS_LIST+="${MAIN_RTB_ID}\n"
  fi
done

# De-duplicate the list and read into a final array
# `grep .` is used to filter out potential blank lines
mapfile -t UNIQUE_TARGET_RTB_IDS < <(echo -e "${TARGET_RTB_IDS_LIST}" | sort -u | grep .)

echo "   Found ${#UNIQUE_TARGET_RTB_IDS[@]} unique route tables to update."


# --- 5. Iterate and create the route (Idempotently) ---
echo "5. Creating routes..."
for rtb_id in "${UNIQUE_TARGET_RTB_IDS[@]}"; do
  echo -n "   Updating ${rtb_id}... "

  # Capture both stdout and stderr into a variable to check for errors
  output=$(aws ec2 create-route $AWS_ARGS \
    --route-table-id "${rtb_id}" \
    --destination-cidr-block "${DEST_CIDR}" \
    --vpc-peering-connection-id "${PEERING_ID}" 2>&1)
  
  exit_code=$? # Get the exit code of the `aws` command

  if [ $exit_code -eq 0 ]; then
    # Command succeeded
    echo "SUCCESS (Route created)"
  else
    # Command failed, check if it's the specific error we want to ignore
    if echo "${output}" | grep -q "RouteAlreadyExists"; then
      echo "SKIPPED (Route already exists)"
    else
      # A different, unexpected error occurred
      echo "FAILED"
      echo "      Error: ${output}" >&2
      # The script will continue to the next route table
    fi
  fi
done

echo "--------------------------------------"
echo "Script completed."
