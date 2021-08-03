#!/usr/bin/env bash

set -e
if [ "$#" -ne 5 ]; then
  echo "ERROR: Incorrect number of arguments, 5 required"
  echo "Usage:"
  echo "  $0 "
  echo "  $1 <AKS_SRVC_USER>"
  echo "  $2 <AKS_SRVC_PASSWORD>"
  echo "  $3 <TENANT_ID>"
  echo "  $4 <RESOURCE_GROUP>"
  echo "  $5 <CLUSTER_NAME>"
  exit 1
fi

AKS_SRVC_USER=$1
AKS_SRVC_PASSWORD=$2
TENANT_ID=$3
RESOURCE_GROUP=$4
CLUSTER_NAME=$5

set -x

az login --service-principal -u ${AKS_SRVC_USER} -p ${AKS_SRVC_PASSWORD} --tenant ${TENANT_ID}
az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --overwrite --admin
