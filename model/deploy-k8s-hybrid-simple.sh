#!/usr/bin/env bash 

echo "begin..."

PGM=$(basename $0)
DIR=$(dirname $0)

MODEL=./k8s-hybrid-simple.json

echo "setting up vars"

ENV=$DIR/env-my-example.sh
if [[ -f "$ENV" ]];then
  echo "sourcing configuration from $ENV"
  . $ENV
fi

if [[ $RESOURCE_GROUP == "" || \
   $LOCATION == "" || \
   $DNS == "" || \
   $ADMIN_USER == "" || \
   $ADMIN_PASSWORD == "" || \
   $SSH_PUBLIC_KEY == "" ]]
then
   echo "Missing env var"
   exit 1
fi

SUB=$(az account show --query id -o tsv 2>&1)
if [ ! $? -eq 0 ]; then
   echo "Error getting subscription:$SUB"
   exit 1
fi
echo "using subscription $SUB"
acs-engine deploy \
--force-overwrite \
--subscription-id $SUB \
--api-model $MODEL \
--location $LOCATION \
--resource-group $RESOURCE_GROUP \
--set orchestratorProfile.kubernetesConfig.privateCluster.jumpboxProfile.publicKey="$SSH_PUBLIC_KEY" \
--set orchestratorProfile.kubernetesConfig.privateCluster.jumpboxProfile.username=$ADMIN_USER \
--set masterProfile.dnsPrefix=$DNS \
--set windowsProfile.adminUsername=$ADMIN_USER \
--set windowsProfile.adminPassword=$ADMIN_PASSWORD \
--set linuxProfile.adminUsername=$ADMIN_USER \
--set linuxProfile.ssh.publicKeys[0].keyData="$SSH_PUBLIC_KEY" 
