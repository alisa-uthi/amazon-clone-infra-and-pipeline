#!/bin/bash

IS_CLUSTER_ONLY=false

usageFunction()
{
   echo
#    echo "Usage: $0 [-e (dev|qa|uat|prod)] [(Optional)[--cluster-only] [true|false]]"
   echo "Usage: $0 [options]"
   {
        echo -e "\t -e \t (Required) Environment name. Possible values: [ dev | qa | uat | prod ]"
        echo -e "\t --cluster-only \t (Optional) Apply change for Kubernetes cluster only."
   } | column -s $'\t' -t
   exit 1
}

optspec=":he:-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                cluster-only)
                    IS_CLUSTER_ONLY="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    if [ -z "$IS_CLUSTER_ONLY" ]
                    then
                        IS_CLUSTER_ONLY=true
                    fi
                    ;;
                cluster-only=*)
                    IS_CLUSTER_ONLY=${OPTARG#*=}
                    opt=${OPTARG%=$IS_CLUSTER_ONLY}
                    ;;
            esac;;
        e ) 
            e=${OPTARG}
            ((e == "dev" || e == "qa" || e == "uat" || e == "prod")) || usageFunction
            ;;
        h)
            usageFunction
            ;;
    esac
done

if [ "$IS_CLUSTER_ONLY" != true ] && [ "$IS_CLUSTER_ONLY" != false ] || [ -z "$e" ]
then
   usageFunction
fi

################## SCRIPT BEGIN ##################
set -e -o pipefail

cd ../$e/kubernetes-cluster

VPC_OUTPUT="../vpc-output.json"

# If AWS VPC configuration has been changed, run Terragrunt to apply changes
if [ $IS_CLUSTER_ONLY == false ]
then 
    echo $'\nAWS VPC configuration has been changed. Will apply those changes...\n';
    terragrunt run-all apply --terragrunt-non-interactive --terragrunt-exclude-dir "cluster-s3-bucket"
    terragrunt run-all output --terragrunt-include-dir "vpc" -json > $VPC_OUTPUT 
fi

echo "------------ BEGIN ------------"
echo "Applying Kubernetes Cluster Configuration..." 

BUCKET_NAME="$(jq --raw-output '.env.value' $VPC_OUTPUT)-kubernetes-cluster-state"
WORKING_DIR="./cluster"

export KOPS_CLUSTER_NAME="$(jq '.kubernetes_cluster_name.value' $VPC_OUTPUT)"
export KOPS_STATE_STORE="s3://$BUCKET_NAME"

echo "Generating kubernetes-cluster.yaml from template..." 
kops toolbox template --values $VPC_OUTPUT --template $WORKING_DIR/cluster-template.yaml --set-string bucket_name=$BUCKET_NAME --out $WORKING_DIR/kubernetes-cluster.yaml

echo "Replacing a resource desired configuration..." 
kops replace -f $WORKING_DIR/kubernetes-cluster.yaml --force

echo "------------ DONE ------------"

# kops export kubecfg --admin

###### Need to run manually ######
# export KOPS_STATE_STORE=s3://dev-kubernetes-cluster-state
# export KOPS_CLUSTER_NAME=kube.alisauthi.top
# kops update cluster --yes
