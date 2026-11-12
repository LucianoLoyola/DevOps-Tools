#!/bin/bash
#
# ROLLBACK SCRIPT
# Finds any route table in the VPC with the specific peering route and removes it.
#

# --- Configuration Parameters (Must match the update script) ---
VPC_ID="<vpc-id>"
REGION="us-east-1"
DEST_CIDR="<destination-cidr>"
PEERING_ID="<peering-connection-id>"

# --- Script Setup ---
set -uo pipefail
AWS_ARGS="--region ${REGION} --output json"

echo "--- Starting Rollback (Route Deletion) ---"
echo "VPC:         ${VPC_ID}"
echo "Region:      ${REGION}"
echo "Target CIDR: ${DEST_CIDR}"
echo "Peering ID:  ${PEERING_ID}"
echo "------------------------------------------"

# --- 1. Find Route Tables containing the specific route ---
echo "1. Searching for route tables containing the route..."

# We filter by VPC, Destination CIDR, AND the Peering ID to ensure 
# we don't delete a route pointing to a different target (safety check).
mapfile -t TARGET_RTB_IDS < <(aws ec2 describe-route-tables $AWS_ARGS \
  --filters "Name=vpc-id,Values=${VPC_ID}" \
            "Name=route.destination-cidr-block,Values=${DEST_CIDR}" \
            "Name=route.vpc-peering-connection-id,Values=${PEERING_ID}" \
  | jq -r '.RouteTables[].RouteTableId')

if [ ${#TARGET_RTB_IDS[@]} -eq 0 ]; then
  echo "   No route tables found with this specific route configuration."
  echo "   Rollback not needed or already completed."
  exit 0
fi

echo "   Found ${#TARGET_RTB_IDS[@]} route tables to clean up."

# --- 2. Iterate and Delete ---
echo "2. Deleting routes..."

for rtb_id in "${TARGET_RTB_IDS[@]}"; do
  echo -n "   Cleaning ${rtb_id}... "

  output=$(aws ec2 delete-route $AWS_ARGS \
    --route-table-id "${rtb_id}" \
    --destination-cidr-block "${DEST_CIDR}" 2>&1)

  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    echo "SUCCESS (Route deleted)"
  else
    # Check if it failed because the route was arguably already gone (race condition)
    if echo "${output}" | grep -q "InvalidRoute"; then
      echo "SKIPPED (Route already gone)"
    else
      echo "FAILED"
      echo "      Error: ${output}" >&2
    fi
  fi
done

echo "------------------------------------------"
echo "Rollback completed."
