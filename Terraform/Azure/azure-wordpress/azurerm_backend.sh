#!/bin/bash

RESOURCE_GROUP_NAME=TF-RG
STORAGE_ACCOUNT_NAME=stgaccttfstate$RANDOM
CONTAINER_NAME=containertfstate

# Get resource group
#az group show --name $RESOURCE_GROUP_NAME

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
