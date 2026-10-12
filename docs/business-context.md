# Business Context
Fictional RBI-regulated payment aggregator mid-tier 45k merchants e-commerce edtech gaming.
3.2M/day 500 Cr volume, peak 1200 TPS normal 2500 Diwali 4000 sale, mix 60% UPI 25% cards 10% wallets 5% NetBanking.
Current pain: single region ap-south-1 2 AZs no auto-failover Aurora single cluster daily snapshots Redis EC2 no replication Kafka single RTO 4-6h manual RPO 24h. 2024 outage 3h cost 60 Cr + RBI notice.
Stakeholders BCRB: CTO feasibility, CRO risk quantification, Compliance Head evidence, VP Eng 8-person operability, Big Four Auditor cost.
Success: automated failover <5min RPO <60s zero double-spend data stays India cost <2 Cr extra vs 145 Cr risk 12 runbooks L1 executable.


## 📸 Architecture Diagrams (Visible in Repo)

### Figure 1: Multi-Region DR Architecture Overview
[Figure 1 - Architecture Overview](../demo/image_20261012_114904.png)
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
[Figure 2 - RPO/RTO Timeline](../demo/image_20261012_114941.png)
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

