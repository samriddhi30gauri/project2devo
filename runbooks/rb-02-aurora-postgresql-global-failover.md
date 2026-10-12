# RB-02: Aurora Global Failover
Pre-req: Confirm primary truly down, not network partition.
Commands:
aws rds describe-global-clusters --global-cluster-identifier paysecure-global
aws rds failover-global-cluster --global-cluster-identifier paysecure-global --target-db-cluster-identifier arn:aws:rds:ap-south-2:ACCOUNT:cluster:paysecure-secondary --region ap-south-1
If primary region API down, use DR region:
aws rds failover-global-cluster --global-cluster-identifier paysecure-global --target-db-cluster-identifier arn:aws:rds:ap-south-2:ACCOUNT:cluster:paysecure-secondary --region ap-south-2
Monitor: aws rds describe-global-clusters --query "GlobalClusters[0].Status"
Expected: <60s promotion, new writer in ap-south-2
Verify: psql $DR_ENDPOINT -c "SELECT pg_is_in_recovery();" should be false (writer)
Post: Update Secrets Manager endpoint, restart payment-api pods: kubectl rollout restart deployment/payment-api -n paysecure --context paysecure-hyderabad
