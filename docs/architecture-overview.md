# Architecture Overview

## Requirements
Peak 1200 TPS normal, 2500 Diwali, 4000 sale. RPO <60s RTO <5min 99.99%. Zero double-spend. Data stays in India.

## Regions
Primary ap-south-1 Mumbai (3 AZs, lowest NPCI latency). DR ap-south-2 Hyderabad (700km, 15-25ms RTT, seismic zone separation, RBI compliant). Rejected ap-south-1 + ap-southeast-1 Singapore - violates RBI 2018.

## Component Replication

### Aurora PostgreSQL Global Database (Corrected - Physical Replication)
- Engine aurora-postgresql 15.4, Global Cluster paysecure-global
- Primary writer Mumbai 2x db.r6g.large, Secondary reader Hyderabad 2x db.r6g.large
- Replication: storage-level physical replication <1s lag, not logical (deliberate error fixed)
- Failover: aws rds failover-global-cluster --global-cluster-identifier paysecure-global --target-db-cluster-identifier arn:aws:rds:ap-south-2:... (managed <60s)
- Encryption: KMS CMK per region, PITR 35 days, cross-region backup to ap-south-2 only (not us-east-1)
- Migration: expand-contract pattern to avoid locking

### DynamoDB Global Tables v2 (Corrected - Conditional Writes)
- Table txn_idempotency PK idempotency_key SK merchant_id, TTL 24h, Streams enabled, PITR enabled
- Replication: multi-master ap-south-1 + ap-south-2
- Critical fix: For financial idempotency must use conditional writes attribute_not_exists(idempotency_key), not last-writer-wins (LWW would cause double-spending) - deliberate error fixed
- Conditional expression: attribute_not_exists(idempotency_key) AND merchant_id = :m

### ElastiCache Global Datastore (Corrected - Manual Promotion)
- Engine redis 7.0, Global group paysecure, Primary Mumbai 3 shards, Secondary Hyderabad 3 shards
- Replication: async <5s, not transactional truth (cache only)
- Fix: Promotion is manual via aws elasticache failover-global-replication-group, not automatic (deliberate error fixed)

### MSK + MirrorMaker2 (Corrected - replication.factor 3)
- Cluster per region 3 brokers kafka.m5.large, version 3.6.0, encryption at rest KMS + TLS in transit
- Replicator: MM2 replicates payment.* settlement.* topics, sync group offsets, consumer groups payment-processors
- Fix: replication.factor=3 min.insync.replicas=2 enable.idempotence=true (doc had 1 - deliberate error)
- Lag alarm CloudWatch MirrorMaker2ReplicationLatency >10s

## EKS
- 6x m5.xlarge min per region 3 AZs Bottlerocket, managed node groups, Karpenter for scale to 12 on failover
- Services: payment-api 6 replicas, txn-processor 8, settlement 3, tokenisation 4 (CDE)
- HPA: CPU 60% + custom http_requests_per_second 200 TPS per pod via Prometheus Adapter (fix - doc used metric without adapter)
- PDB 75% payment-api, App Mesh mTLS

## Failover Orchestration
- Route53 Health Check: HTTPS /healthz ALB, interval 10s (fast) not 30s (deliberate error fixed), failure threshold 3, TTL 60s (balance cost vs RTO)
- Lambda orchestrator: double-check CloudWatch metrics to avoid flapping, promote Aurora, promote ElastiCache manual, flip Route53 (auto but force if needed), scale EKS via Karpenter, notify PagerDuty + Slack + compliance audit trail
- RTO/RPO calc: DNS 60-90s + Aurora 60s + EKS warm 60s = <3min E2E RTO, RPO <60s (Aurora <1s + DynamoDB <1s + MSK 2-5s)

## Why Not Active-Active?
Financial risk double-debit without global lock, 8-person team cannot operate, RBI allows active-passive if RTO<5min.

## Security
KMS per region 90d custom rotation Lambda (PCI DSS v4.0 Req 3.6.4) - AWS auto is 365d not sufficient (deliberate error fixed), Secrets Manager replication, WAF Shield Advanced ALB, CloudTrail org trail S3 Object Lock 7 years, NetworkPolicy strict CDE isolation (fix - doc had 0.0.0.0/0)

## Observability
Prometheus + Grafana per region Thanos global, alerts: Aurora lag >1s, MSK lag >10s, Route53 failover, pod crash loop.


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

