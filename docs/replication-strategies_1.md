# Replication Strategies

## Aurora Global
Physical storage replication <1s, failover managed.
Commands:
aws rds describe-global-clusters --global-cluster-identifier paysecure-global
aws rds failover-global-cluster --global-cluster-identifier paysecure-global --target-db-cluster-identifier arn:aws:rds:ap-south-2:ACCOUNT:cluster:paysecure-secondary
Verify: SELECT pg_is_in_recovery(); should be false for writer.

## DynamoDB
Table txn_idempotency with conditional write attribute_not_exists. Streams -> Lambda audit. TTL 24h.

## ElastiCache
Global datastore paysecure-global-cache, primary Mumbai secondary Hyderabad, promotion manual:
aws elasticache failover-global-replication-group --global-replication-group-id paysecure --primary-replication-group-id paysecure-secondary

## MSK MM2
Config replication.factor 3 min.insync 2, topics payment.* settlement.*, enable.idempotence true, consumer manual commit after DB commit.
