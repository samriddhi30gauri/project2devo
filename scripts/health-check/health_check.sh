#!/bin/bash
set -e
echo "=== PaySecure Health ==="
aws rds describe-global-clusters --query "GlobalClusters[?GlobalClusterIdentifier=='paysecure-global']"
aws dynamodb describe-table --table-name txn_idempotency --query "Table.Replicas"
aws elasticache describe-global-replication-groups --global-replication-group-id paysecure
kubectl --context paysecure-mumbai get nodes
kubectl --context paysecure-hyderabad get nodes
