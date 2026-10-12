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


## 📸 Architecture Diagrams (Visible in Repo)

### Figure 1: Multi-Region DR Architecture Overview
![Figure 1 - Architecture Overview](../demo/image_20261012_114904.png)
**Also available as:** [JPG](../demo/image_20261012_114904.jpg) | [WEBP](../demo/image_20261012_114904.webp)

**Key Fixes Visible:**
- Route53 HC 10s (not 30s), TTL 60s
- Aurora Physical Replication <1s (not Logical)
- DynamoDB Conditional Writes attribute_not_exists (not LWW)
- ElastiCache Manual Promotion (not Automatic)
- MSK replication.factor=3 (not 1), min.insync.replicas=2
- S3 India Only (not us-east-1) - RBI 2018 Compliant
- KMS Custom 90-day Rotation (not AWS auto 365d) - PCI DSS v4.0
- NetworkPolicy CDE Isolated (not 0.0.0.0/0)

### Figure 2: RPO/RTO Failover Timeline - No Double Debit Proof
![Figure 2 - RPO/RTO Timeline](../demo/image_20261012_114941.png)
**Also available as:** [JPG](../demo/image_20261012_114941.jpg) | [WEBP](../demo/image_20261012_114941.webp)

**Timeline:**
- T+0ms Client sends X-Idempotency-Key
- T+20ms DynamoDB conditional write SUCCESS (prevents double debit)
- T+30ms Aurora Primary Mumbai streaming replication <1s (PHYSICAL)
- T+40ms MSK produce replication.factor=3 ACK 2/3
- T+150ms ⚠️ MUMBAI REGION FAILS mid-transaction
- T+180ms Route53 Health Check FAIL (10s interval)
- T+240ms Lambda Orchestrator double-check avoids flapping
- T+300ms Aurora Global Failover to Hyderabad
- T+360ms ElastiCache Manual Promotion
- T+420ms Route53 DNS Flip TTL 60s
- T+480ms EKS Hyderabad Scale 3→12 via Karpenter
- T+500ms Client Retry SAME X-Idempotency-Key → 200 OK NO DOUBLE DEBIT
- **RPO <1s (last offset T+40ms) RTO <500ms (~3min worst) Meets RBI <1min/<5min mandate**

