# BCRB 10 Challenge Questions

Q1 CTO: What happens to transaction mid-flight when Mumbai dies at T+150ms?
A: Client retries same idempotency key, DynamoDB Global already has key (written T+20ms), DR returns existing status, no double debit. Aurora txn may not commit - settlement replays from Kafka outbox.

Q2 CRO: Quantify split-brain financial exposure?
A: Worst 90s both regions active (DNS TTL 60s + HC 30s) 1200 TPS *90s=108k txns *2500 INR=27 Cr exposure if no fencing, 0 with DynamoDB conditional writes.

Q3 Compliance Head: Cardholder data residency during failover?
A: PAN tokenised via CloudHSM India, Aurora only token, KMS Hyderabad, no cross-border.

Q4 VP Eng: Can 8-person team operate?
A: Yes active-passive + IaC + managed services + runbooks, on-call 1 primary.

Q5 Auditor: DNS TTL impact real RTO?
A: P95 90s Route53 +60s TTL +30s ALB dereg=180s still <5min. Use ARC for faster.

Q6 CTO: Kafka partition loss?
A: MM2 acks=all min.insync=2 0 loss single broker, region loss 2-5s reconciled via Lambda replay.

Q7 CRO: Settlement discrepancy?
A: Idempotent ledger + pause 2min + checkpoint DynamoDB + daily NPCI reconciliation.

Q8 Compliance: Audit trail continuity?
A: CloudTrail org trail S3 Mumbai + replication Hyderabad Object Lock 7y.

Q9 VP Eng: Cost sustainability?
A: $16.5k/mo vs $8.5k single, 90x ROI vs 145 Cr risk, warm standby.

Q10 Auditor: Chaos testing?
A: Monthly FIS kill AZ/region/Aurora/MSK, recorded RB-12.


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


### How to Use Figure 2 for BCRB Board
- Q1 CTO (Mid-flight failure): Show T+150ms failure -> T+500ms idempotent retry
- Q5 Auditor (Real RTO): Show bottom timeline bar RPO <1s RTO <500ms + Compliance PASSED boxes
- Q9 Split-brain: Show 0 financial exposure with conditional writes vs 27 Cr without
