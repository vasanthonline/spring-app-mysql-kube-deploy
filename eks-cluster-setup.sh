#!/usr/bin/env bash

# ************************************************************************
# ************************************************************************
# 
# To setup a new cluster and node group via EKS. 
# 
# Prerequisite: 
# 1. eksctl setup using https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
# 2. Instance SSH key setup using https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#prepare-key-pair
# ************************************************************************
# ************************************************************************

# ************************************************************************
# CONFIGURATION PARAMETERS FOR THE SCRIPT

CLUSTER_NAME="<TODO_CLUSTER_NAME>"
CLUSTER_REGION="<TODO_CLUSTER_REGION>"
CLUSTER_NODE_GROUP="<TODO_CLUSTER_NODE_GROUP>"
CLUSTER_NODE_GROUP_TYPE="<TODO_CLUSTER_NODE_GROUP_TYPE>" # Eg: t2.micro.
CLUSTER_NODES_COUNT="<TODO_CLUSTER_NODES_COUNT>"
CLUSTER_NODES_MIN="<TODO_CLUSTER_NODES_MIN>"
CLUSTER_NODES_MAX="<TODO_CLUSTER_NODES_MIN>"
CLUSTER_SSH_KEY="<TODO_CLUSTER_SSH_KEY>" # Path to the SSH key to the instance. 

# ************************************************************************


# ************************************************************************

eksctl create cluster --name $CLUSTER_NAME --version 1.17 --without-nodegroup --region $CLUSTER_REGION

eksctl create nodegroup --cluster $CLUSTER_NAME --region $CLUSTER_REGION --name $CLUSTER_NODE_GROUP --node-type $CLUSTER_NODE_GROUP_TYPE --nodes $CLUSTER_NODES_COUNT --nodes-min $CLUSTER_NODES_MIN --nodes-max $CLUSTER_NODES_MAX --ssh-access --ssh-public-key $CLUSTER_SSH_KEY --managed