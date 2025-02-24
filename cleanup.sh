#!/bin/bash
set -e  # Exit script on error

# 🔹 PROMPT USER FOR LINODE API TOKEN
read -sp "Enter your Linode API Token: " LINODE_CLI_TOKEN
echo ""

# Set Linode CLI token
export LINODE_CLI_TOKEN=$LINODE_CLI_TOKEN
linode-cli configure set token $LINODE_CLI_TOKEN

echo "⚡ Starting Linode Environment Cleanup..."

# Function to delete LKE Cluster
cleanup_lke() {
    echo "🛑 Deleting Linode Kubernetes Engine (LKE) Clusters..."
    
    clusters=$(linode-cli lke clusters-list --json | jq -r '.[].id')

    for cluster in $clusters; do
        echo "Deleting LKE Cluster ID: $cluster"
        linode-cli lke cluster-delete "$cluster"
    done
}

# Function to delete Linode Volumes
cleanup_volumes() {
    echo "🗑️ Deleting Linode Volumes..."
    
    volumes=$(linode-cli volumes list --json | jq -r '.[].id')

    for volume in $volumes; do
        echo "Deleting volume ID: $volume"
        linode-cli volumes delete "$volume"
    done
}

# Function to delete Linode Object Storage Buckets
cleanup_object_storage() {
    echo "🗑️ Deleting Linode Object Storage Buckets..."
    
    buckets=$(linode-cli obj list-buckets --json | jq -r '.[].label')

    for bucket in $buckets; do
        echo "Deleting bucket: $bucket"
        linode-cli obj rm --recursive "s3://${bucket}"
        linode-cli obj delete-bucket "${bucket}"
    done
}

# Function to delete Linodes (VMs)
cleanup_linodes() {
    echo "🗑️ Deleting all Linode Instances..."
    
    linodes=$(linode-cli linodes list --json | jq -r '.[].id')

    for linode in $linodes; do
        echo "Deleting Linode ID: $linode"
        linode-cli linodes delete "$linode"
    done
}

# Function to delete NodeBalancers
cleanup_nodebalancers() {
    echo "🗑️ Deleting Linode NodeBalancers..."
    
    nodebalancers=$(linode-cli nodebalancers list --json | jq -r '.[].id')

    for nodebalancer in $nodebalancers; do
        echo "Deleting NodeBalancer ID: $nodebalancer"
        linode-cli nodebalancers delete "$nodebalancer"
    done
}

# Function to delete Domain DNS Records
cleanup_domains() {
    echo "🗑️ Deleting Linode DNS Domains..."
    
    domains=$(linode-cli domains list --json | jq -r '.[].id')

    for domain in $domains; do
        echo "Deleting Domain ID: $domain"
        linode-cli domains delete "$domain"
    done
}

# 🚀 EXECUTE CLEANUP
cleanup_lke
cleanup_volumes
cleanup_object_storage
cleanup_linodes
cleanup_nodebalancers
cleanup_domains

echo "✅ Cleanup Completed! All Linode resources have been removed."