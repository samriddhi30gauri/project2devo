# RB-04: ElastiCache Global Promotion
Note: Manual promotion, not automatic (common error).
Command:
aws elasticache failover-global-replication-group --global-replication-group-id paysecure --primary-replication-group-id paysecure-secondary --region ap-south-1
If primary region down, run from secondary:
aws elasticache failover-global-replication-group --global-replication-group-id paysecure --primary-replication-group-id paysecure-secondary --region ap-south-2
Monitor: aws elasticache describe-global-replication-groups --global-replication-group-id paysecure
Expected: Role of paysecure-secondary becomes PRIMARY in <30s
Post: Flush app cache or let TTL handle, verify hit rate in Grafana.
